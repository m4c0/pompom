type id = string * string * string
type bom = string Ga_map.t
type modules = string list

let prop_regex = Str.regexp "\\${\\(.*\\)}"

let rec apply_props (i : Inheritor.t) (s : string) : string =
  let fn pp =
    let p = Str.matched_group 1 pp in
    match Inheritor.PropMap.find_opt p i.props with
    | Some x -> x
    | None -> failwith (p ^ ": property not found")
  in
  let res = Str.global_substitute prop_regex fn s in
  if res = s then res else apply_props i res

let rec merge_dm (i : Inheritor.t) =
  let read_merge ((g, a), ({ version; _ } : Inheritor.dm)) =
    apply_props i version |> Repo.asset_fname "pom" g a |> Inheritor.read_pom
    |> merge_dm
  in
  let folder (acc : Inheritor.t) (i : Inheritor.t) =
    let deps = Ga_map.merge acc.deps i.deps in
    let dep_mgmt = Ga_map.merge acc.dep_mgmt i.dep_mgmt in
    { acc with deps; dep_mgmt }
  in
  let is_bom (_, ({ scope; tp; _ } : Inheritor.dm)) =
    scope = Some "import" && tp = Some "pom"
  in
  Ga_map.to_seq i.dep_mgmt |> Seq.filter is_bom |> Seq.map read_merge
  |> Seq.fold_left folder i

let dep_from (dm : Inheritor.dm_map) (g, a) ({ version; _ } : Inheritor.dep) =
  match version with
  | Some x -> x
  | None -> (
      match Ga_map.find_opt (g, a) dm with
      | Some { version; _ } -> version
      | None -> "could not find version for " ^ g ^ ":" ^ a |> failwith)

let resolve_dep_versions (s : Scopes.t) (i : Inheritor.t) =
  let fn k (v : Inheritor.dep) : string option =
    if Scopes.matches s v.scope then
      Some (dep_from i.dep_mgmt k v |> apply_props i)
    else None
  in
  Ga_map.filter_map fn i.deps

let resolve (scope : Scopes.t) pom_fname : id * bom * modules =
  let i = Inheritor.read_pom pom_fname |> merge_dm in
  let deps = resolve_dep_versions scope i in
  ((i.id.ga.group, i.id.ga.artifact, i.id.version), deps, i.modules)
