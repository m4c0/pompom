let has_scope (s : Scopes.t) (d : Pom.dep) : bool = Scopes.matches s d.scope

let find_version (dm : Pom.dep Ga_map.t) (d : Pom.dep) : Pom.dep =
  match d.version with
  | Some _ -> d
  | None -> (
      match Ga_map.find_opt d.ga dm with
      | Some { version = Some v; _ } -> { d with version = Some v }
      | _ ->
          "could not find version for " ^ d.ga.group ^ ":" ^ d.ga.artifact
          |> failwith)

let shallow_resolve (scope : Scopes.t) (fname : string) : Aggregator.t =
  let p = Inheritor.parse_and_merge fname in
  let props = Propinator.of_seq p.props in
  let dm = Boomer.build_bom p in
  let deps =
    p.deps
    |> Seq.filter (has_scope scope)
    |> Seq.map (find_version dm)
    |> Seq.map (Propinator.apply_to_dep props p)
  in
  Aggregator.aggregate { p with deps }

let resolve (scope : Scopes.t) (fname : string) : Aggregator.t =
  let shallow_dive ((ga : Pom.ga), v) =
    Repo.asset_fname "pom" ga.group ga.artifact v
    |> shallow_resolve scope |> Aggregator.deps_of |> Ga_map.to_seq
  in
  let rec deep_dive deps =
    let version_isnt_set ((ga : Pom.ga), _) =
      Ga_map.GAMap.exists (fun k _ -> k = ga) deps |> not
    in
    let new_deps =
      Ga_map.to_seq deps |> Seq.flat_map shallow_dive
      |> Seq.filter version_isnt_set
      |> Ga_map.of_seq
    in
    if Ga_map.GAMap.is_empty new_deps then deps
    else deep_dive new_deps |> Ga_map.GAMap.merge Map_utils.closest_merger deps
  in

  let agg = shallow_resolve scope fname in
  let deps = deep_dive agg.deps in
  { agg with deps }
