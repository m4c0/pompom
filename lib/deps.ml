type id = string * string * string
type bom = string Ga_map.t
type modules = string list
type dep = Pom.dep

let has_scope (s : Scopes.t) (d : dep) : bool = Scopes.matches s d.scope

let find_version (dm : dep Ga_map.t) (d : dep) : dep =
  match d.version with
  | Some _ -> d
  | None -> (
      match Ga_map.find_opt d.ga dm with
      | Some { version = Some v; _ } -> { d with version = Some v }
      | _ ->
          "could not find version for " ^ d.ga.group ^ ":" ^ d.ga.artifact
          |> failwith)

let resolve (scope : Scopes.t) pom_fname : id * bom * modules =
  let p = Inheritor.parse_and_merge pom_fname in
  let props = Propinator.of_seq p.props in
  let dm = Boomer.build_bom p in
  let deps =
    p.deps
    |> Seq.filter (has_scope scope)
    |> Seq.map (find_version dm)
    |> Seq.map (Propinator.apply_to_dep props)
  in

  let a = Aggregator.aggregate { p with deps } in
  (a.id, a.deps, a.modules)
