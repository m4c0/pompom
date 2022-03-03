type id = string * string * string
type bom = string Ga_map.t
type modules = string list
type dep = Pom.dep

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
    let mapper _ = dep_from i.dep_mgmt k v in
    Scopes.map_if_matches s v.scope mapper
  in
  Ga_map.filter_map fn i.deps

let resolve (scope : Scopes.t) pom_fname : id * bom * modules =
  let i = Aggregator.read_pom pom_fname in
  let deps = resolve_dep_versions scope i in
  (i.id, deps, i.modules)
