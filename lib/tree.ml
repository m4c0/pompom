type t = {
  id : Pom.id;
  deps : Dependency.t Seq.t;
  resolver : Pom.id -> t;
  modules : string Seq.t;
  props : Properties.t Seq.t;
}

let seq_or_die fld msg (seq : 'a Seq.t) =
  match seq () with Nil -> Errors.fail fld msg | Cons (v, _) -> v

let id_of (tt : t) = tt.id
let modules_seq (tt : t) = tt.modules

let find_ver (d : Dependency.t) =
  let g, a, ov = Dependency.id_of d in
  let v = Option.to_seq ov |> seq_or_die (g ^ ":" ^ a) "missing version" in
  Seq.return (g, a, v)

let rec resolve exists (tt : t) : Pom.id Seq.t =
  let apply_props (g, a, v) =
    let apply = Properties.apply tt.props in
    (apply g, apply a, apply v)
  in

  let this =
    Seq.filter (Fun.negate exists) tt.deps
    |> Seq.flat_map find_ver |> Seq.map apply_props |> Depmap.of_seq
  in
  let exists (d : Dependency.t) = exists d || Depmap.exists d.ga this in
  let this_seq = Depmap.to_seq this in
  this_seq |> Seq.map tt.resolver
  |> Seq.flat_map (resolve exists)
  |> Seq.append this_seq

let deps_seq (tt : t) = resolve (fun _ -> false) tt

let parser_id (p : Parser.t) (parent : Pom.id Seq.t) : Pom.id =
  let gv fld o fn =
    let opt = Option.to_seq o in
    parent |> Seq.map fn |> Seq.append opt |> seq_or_die fld "missing field"
  in
  let g = gv "groupId" p.id.group (fun (g, _, _) -> g) in
  let a = p.id.artifact in
  let v = gv "version" p.id.version (fun (_, _, v) -> v) in
  (g, a, v)

let props_of (p : Parser.t) id parent =
  let my_props = Properties.of_seq p.props in
  let def_props = Properties.of_id id in
  let parent_props = Seq.flat_map (fun p -> p.props) parent in
  List.to_seq [ my_props; def_props; parent_props ] |> Seq.concat

let rec build_tree (scope : Scopes.t) (fname : string) : t =
  let p = Parser.parse_file fname in

  let parent =
    p.parent
    |> Option.map (fun (g, a, v) -> Repo.asset_fname "pom" g a v)
    |> Option.map (build_tree scope)
    |> Option.to_seq
  in
  let id = parent |> Seq.map (fun p -> p.id) |> parser_id p in
  let modules = p.modules in
  let props = props_of p id parent in

  let my_deps = p.deps in
  let parent_deps = Seq.flat_map (fun p -> p.deps) parent in
  let deps = List.to_seq [ my_deps; parent_deps ] |> Seq.concat in

  let transitive_scope = Scopes.transitive_of scope in
  let resolver (g, a, v) =
    Repo.asset_fname "pom" g a v |> build_tree transitive_scope
  in

  { id; deps; modules; props; resolver }
