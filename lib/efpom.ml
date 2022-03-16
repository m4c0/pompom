type id = string * string * string

type t = {
  id : id;
  modules : string Seq.t;
  parent : id option;
  properties : Properties.t;
  depmgmt : Efdep.t Depmap.t;
  deps : Efdep.t Depmap.t;
}

let id_of t = t.id
let modules_of t = t.modules
let parent_of t = t.parent
let properties_of t = Properties.to_seq t.properties
let depmgmt_of t = Depmap.to_seq t.depmgmt |> Seq.map (fun (_, v) -> v)
let deps_of t = Depmap.to_seq t.deps |> Seq.map (fun (_, v) -> v)

let depmap_from_seq dm ps =
  ps
  |> Seq.map (fun k -> (Dependency.unique_key k, k))
  |> Depmap.of_seq
  |> Depmap.map (Efdep.of_parsed dm)

let normalise_dep props (d : Dependency.t) =
  let apply = Properties.apply props in
  let ga : Dependency.ga =
    { group = apply d.ga.group; artifact = apply d.ga.artifact }
  in
  let version = Option.map apply d.version in
  let classifier =
    match Option.map (Properties.apply props) d.classifier with
    | Some "" -> None
    | x -> x
  in
  { d with ga; version; classifier }

let rec try_from_pom fname : t =
  let i = Inheritor.parse fname in

  let properties =
    Properties.of_id i.id
    |> Properties.merge_right i.properties
    |> Properties.resolve
  in

  let all_dm =
    depmap_from_seq Depmap.empty i.depmgmt
    |> Depmap.map (Efdep.apply_props properties)
    |> Depmap.to_seq
  in
  let read_bom (_, d) =
    let p = Efdep.filename_of d |> try_from_pom in
    Depmap.to_seq p.depmgmt
  in

  let non_bom =
    Seq.filter_map
      (fun (k, d) -> if Efdep.is_bom d then None else Some (k, d))
      all_dm
  in
  let bom =
    Seq.filter_map
      (fun (k, d) -> if Efdep.is_bom d then Some (k, d) else None)
      all_dm
    |> Seq.flat_map read_bom
  in
  let depmgmt = Seq.append non_bom bom |> Depmap.of_seq in

  let deps =
    Seq.map (normalise_dep properties) i.deps |> depmap_from_seq depmgmt
  in

  {
    id = i.id;
    parent = i.parent;
    properties;
    depmgmt;
    deps;
    modules = i.modules;
  }

let from_pom fname : t =
  try try_from_pom fname with Failure x -> failwith (x ^ "\nfrom " ^ fname)

let from_dep (d : Efdep.t) = Efdep.filename_of d |> from_pom
let from_java fname = Repo.pom_of_java fname |> from_pom
