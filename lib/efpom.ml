type id = string * string * string

type dep = {
  id : id;
  exclusions : (string * string) Seq.t;
  classifier : string option;
  optional : bool;
  scope : string;
  tp : string;
  is_bom : bool;
}

type t = {
  id : id;
  modules : string Seq.t;
  parent : id option;
  properties : Properties.t;
  depmgmt : dep Depmap.t;
  deps : dep Depmap.t;
}

let id_of t = t.id
let modules_of t = t.modules
let parent_of t = t.parent
let properties_of t = Properties.to_seq t.properties
let depmgmt_of t = Depmap.to_seq t.depmgmt |> Seq.map (fun (_, v) -> v)
let deps_of t = Depmap.to_seq t.deps |> Seq.map (fun (_, v) -> v)

let dep_of_parsed (dm : dep Depmap.t) (d : Dependency.t) : dep =
  let dmopt = Depmap.find_opt (Dependency.unique_key d) dm in
  let dm_v = Option.map (fun ({ id = _, _, v; _ } : dep) -> v) dmopt in
  let dm_exc =
    Option.map (fun (d : dep) -> d.exclusions) dmopt
    |> Option.to_seq |> Seq.concat
  in
  {
    classifier = Dependency.classifier_of d;
    id = Dependency.id_of dm_v d;
    exclusions = Dependency.exclusions_of d |> Seq.append dm_exc;
    optional = Dependency.is_optional d;
    scope = Dependency.scope_of d;
    tp = Dependency.tp_of d;
    is_bom = Dependency.is_bom d;
  }

let depmap_from_seq dm ps =
  ps
  |> Seq.map (fun k -> (Dependency.unique_key k, k))
  |> Depmap.of_seq
  |> Depmap.map (dep_of_parsed dm)

let resolve_id (props : Properties.t) ((g, a, v) : id) =
  let apply = Properties.apply props in
  (apply g, apply a, apply v)

let resolve_depmap (props : Properties.t) (dm : dep) =
  let id = resolve_id props dm.id in
  let classifier =
    match Option.map (Properties.apply props) dm.classifier with
    | Some "" -> None
    | x -> x
  in
  { dm with id; classifier }

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

let rec from_pom fname : t =
  let i = Inheritor.parse fname in

  let properties =
    Properties.of_id i.id
    |> Properties.merge_right i.properties
    |> Properties.resolve
  in

  let all_dm =
    depmap_from_seq Depmap.empty i.depmgmt
    |> Depmap.map (resolve_depmap properties)
    |> Depmap.to_seq
  in
  let read_bom (_, ({ id = g, a, v; _ } : dep)) =
    let p = Repo.asset_fname "pom" g a v |> from_pom in
    Depmap.to_seq p.depmgmt
  in

  let non_bom =
    Seq.filter_map (fun (k, d) -> if d.is_bom then None else Some (k, d)) all_dm
  in
  let bom =
    Seq.filter_map (fun (k, d) -> if d.is_bom then Some (k, d) else None) all_dm
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

let from_dep (d : dep) =
  let g, a, v = d.id in
  Repo.asset_fname "pom" g a v |> from_pom

let from_java fname = Repo.pom_of_java fname |> from_pom
