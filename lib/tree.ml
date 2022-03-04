type t = {
  id : string * string * string;
  parent : t option;
  deps : Dependency.map;
  dm : Dependency.map;
  parsed : Parser.t;
}

let id_of (tt : t) = tt.id
let ( |? ) opt fn = match opt with Some x -> Some x | None -> fn ()
let ( |! ) opt fn = match opt with Some x -> x | None -> fn ()

let rec deps_seq (tt : t) =
  let fn (d : Dependency.t) =
    let fail () =
      Errors.fail (d.ga.group ^ ":" ^ d.ga.artifact) "could not resolve version"
    in
    let try_parent () =
      Option.bind tt.parent (fun (p : t) -> Dependency.Map.find_opt d.ga p.dm)
      |> Option.map Dependency.version_of
      |> Option.join
    in

    let v = d.version |? try_parent |! fail in
    (d.ga.group, d.ga.artifact, v)
  in
  let hasnt_dep (group, artifact, _) =
    Dependency.Map.find_opt { group; artifact } tt.deps |> Option.is_none
  in
  let parent_deps =
    Option.to_seq tt.parent |> Seq.flat_map deps_seq |> Seq.filter hasnt_dep
  in
  Dependency.seq_of_map tt.deps |> Seq.map fn |> Seq.append parent_deps

let modules_seq (tt : t) = tt.parsed.modules

let rec build_tree (scope : Scopes.t) (fname : string) : t =
  let fail fld = Errors.fail_fn fld "missing field" in
  let p = Parser.parse_file fname in
  let g = p.id.group |? Parent_id.group_fn p.parent |! fail "groupId" in
  let a = p.id.artifact in
  let v = p.id.version |? Parent_id.version_fn p.parent |! fail "version" in
  let recurse (pg, pa, pv) =
    Repo.parent_of_pom fname pg pa pv |> build_tree scope
  in
  let deps = Dependency.map_of_seq p.deps in
  let dm = Dependency.map_of_seq p.dep_mgmt in
  let parent = Option.map recurse p.parent in
  { id = (g, a, v); parent; deps; dm; parsed = p }
