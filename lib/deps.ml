type id = string * string * string
type bom = string Ga_map.t
type modules = string list
type dep = Pom.dep

let dep_from (dm : dep Ga_map.t) ga (d : dep) : string option =
  match d.version with
  | Some x -> Some x
  | None -> (
      match Ga_map.find_opt ga dm with
      | Some { version = Some v; _ } -> Some v
      | _ ->
          "could not find version for " ^ ga.group ^ ":" ^ ga.artifact
          |> failwith)

let resolve_dep_versions (s : Scopes.t) (i : Aggregator.t) k (v : dep) =
  let has_scope = Scopes.matches s v.scope in
  if not has_scope then None else dep_from i.dep_mgmt k v

let resolve (scope : Scopes.t) pom_fname : id * bom * modules =
  let p = Inheritor.parse_and_merge pom_fname in
  let i = Aggregator.read_pom p in
  let deps = Ga_map.filter_map (resolve_dep_versions scope i) i.deps in
  (i.id, deps, i.modules)
