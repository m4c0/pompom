type t = {
  id : Pom.id;
  deps : Dependency.t Seq.t;
  resolver : Pom.id -> t;
  dep_mgmt : Depmgmt.t Seq.t;
  modules : string Seq.t;
  props : Properties.t Seq.t;
}

let seq_or_die fld msg (seq : 'a Seq.t) =
  match seq () with Nil -> Errors.fail fld msg | Cons (v, _) -> v

let id_of (tt : t) = tt.id
let modules_seq (tt : t) = tt.modules

let is_excl excl (d : Dependency.ga) =
  let excl = Seq.filter (fun x -> x = d) excl in
  match excl () with Nil -> false | _ -> true

let%test "is_excl" =
  let ga : Dependency.ga = { group = "aa"; artifact = "bb" } in
  let seq = Seq.return ga in
  is_excl seq ga && is_excl Seq.empty ga |> not

let rec resolve exists excl (tt : t) : Pom.id Seq.t =
  let apply_props (g, a, v, d) =
    let apply = Properties.apply tt.props in
    (apply g, apply a, (apply v, d))
  in
  let find_version (d : Dependency.t) =
    let g, a, _ = Dependency.id_of d in
    let dm fn fld =
      Seq.flat_map (Depmgmt.find d) tt.dep_mgmt
      |> Seq.flat_map fn
      |> seq_or_die (g ^ ":" ^ a) ("missing " ^ fld)
    in
    let v = dm Depmgmt.version_of "version" in
    (g, a, v, d)
  in

  let ex_ex (d : Dependency.t) = exists d || is_excl excl d.ga in

  let deps =
    Seq.filter (Fun.negate ex_ex) tt.deps
    |> Seq.map find_version |> Seq.map apply_props |> Depmap.of_seq
  in
  let exists (d : Dependency.t) = ex_ex d || Depmap.exists d deps in
  let dep_seq = Depmap.to_seq deps in
  let dep_map (g, a, (v, (d : Dependency.t))) =
    let exclusions =
      Seq.flat_map (Depmgmt.find d) tt.dep_mgmt
      |> Seq.flat_map Depmgmt.exclusions_of
    in
    tt.resolver (g, a, v) |> resolve exists exclusions
  in
  let next_seq = Seq.flat_map dep_map dep_seq in
  let this_seq = Seq.map (fun (g, a, (v, _)) -> (g, a, v)) dep_seq in
  Seq.append this_seq next_seq

let deps_seq (tt : t) = resolve (fun _ -> false) Seq.empty tt

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
  let try_build_tree s f =
    try build_tree s f with
    | Failure x -> x ^ "\nwhile parsing " ^ fname |> failwith
    | Sys_error x -> x ^ "\nwhile parsing " ^ fname |> failwith
  in
  let p = Parser.parse_file fname in

  let parent =
    p.parent
    |> Option.map (fun (g, a, v) -> Repo.asset_fname "pom" g a v)
    |> Option.map (try_build_tree scope)
    |> Option.to_seq
  in
  let id = parent |> Seq.map (fun p -> p.id) |> parser_id p in
  let modules = p.modules in
  let props = props_of p id parent in

  let my_deps = Seq.filter (Dependency.has_scope scope) p.deps in
  let parent_deps = Seq.flat_map (fun p -> p.deps) parent in
  let deps = List.to_seq [ my_deps; parent_deps ] |> Seq.concat in

  let transitive_scope = Scopes.transitive_of scope in
  let resolver (g, a, v) =
    Repo.asset_fname "pom" g a v |> try_build_tree transitive_scope
  in

  let deps_dm = Depmgmt.of_dep_seq deps |> Seq.return in
  let bom_dm =
    Seq.filter Dependency.is_bom p.dep_mgmt
    |> Seq.map (Dependency.filename_of "pom")
    |> Seq.map (Properties.apply props)
    |> Seq.map (try_build_tree scope)
    |> Seq.flat_map (fun tt -> tt.dep_mgmt)
  in
  let my_dm =
    Seq.filter (Fun.negate Dependency.is_bom) p.dep_mgmt
    |> Depmgmt.of_dep_seq |> Seq.return
  in
  let parent_dm = parent |> Seq.flat_map (fun p -> p.dep_mgmt) in
  let dep_mgmt =
    [ deps_dm; my_dm; parent_dm; bom_dm ] |> List.to_seq |> Seq.concat
  in

  { id; deps; modules; props; resolver; dep_mgmt }
