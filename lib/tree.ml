type t = {
  id : string * string * string;
  parent : t option;
  modules : string Seq.t;
}

let rec build_tree (scope : Scopes.t) (fname : string) : t =
  let p = Parser.parse_file fname in
  let g =
    Inheritable.get p.id.group
      ~default:(Parent_id.group_fn p.parent)
      ~label:"groupId"
  in
  let a = p.id.artifact in
  let v =
    Inheritable.get p.id.version
      ~default:(Parent_id.version_fn p.parent)
      ~label:"version"
  in
  let recurse (pg, pa, pv) =
    Repo.parent_of_pom fname pg pa pv |> build_tree scope
  in
  let parent = Option.map recurse p.parent in
  { id = (g, a, v); parent; modules = p.modules }
