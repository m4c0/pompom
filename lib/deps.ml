type id = string * string * string
type bom = string Ga_map.t
type modules = string list
type dep = Parser.dep_data

let rec merge_dm (i : Aggregator.t) =
  let read_merge ((ga : Pom.ga), (d : dep)) =
    let g = ga.group in
    let a = ga.artifact in
    let v =
      match d.version with
      | Some vv -> Propinator.apply_props i.props vv
      | None -> Printf.sprintf "missing version for %s:%s" g a |> failwith
    in
    Repo.asset_fname "pom" g a v |> Aggregator.read_pom
  in
  let folder (acc : Aggregator.t) (i : Aggregator.t) =
    let deps = Ga_map.merge acc.deps i.deps in
    let dep_mgmt = Ga_map.merge acc.dep_mgmt i.dep_mgmt in
    { acc with deps; dep_mgmt }
  in
  let is_bom (_, ({ scope; tp; _ } : dep)) =
    scope = Some "import" && tp = Some "pom"
  in
  Ga_map.to_seq i.dep_mgmt |> Seq.filter is_bom |> Seq.map read_merge
  |> Seq.map merge_dm |> Seq.fold_left folder i

let dep_from (dm : dep Ga_map.t) ga (d : dep) =
  match d.version with
  | Some x -> x
  | None -> (
      match Ga_map.find_opt ga dm with
      | Some { version = Some v; _ } -> v
      | _ ->
          "could not find version for " ^ ga.group ^ ":" ^ ga.artifact
          |> failwith)

let resolve_dep_versions (s : Scopes.t) (i : Aggregator.t) =
  let fn k (v : dep) : string option =
    if Scopes.matches s v.scope then
      Some (dep_from i.dep_mgmt k v |> Propinator.apply_props i.props)
    else None
  in
  Ga_map.filter_map fn i.deps

let resolve (scope : Scopes.t) pom_fname : id * bom * modules =
  let i = Aggregator.read_pom pom_fname |> merge_dm in
  let deps = resolve_dep_versions scope i in
  (i.id, deps, i.modules)
