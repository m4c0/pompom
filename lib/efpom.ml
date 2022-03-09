type id = string * string * string

type dep = {
  id : id;
  exclusions : (string * string) Seq.t;
  classifier : string option;
  optional : bool;
  scope : string option;
  tp : string option;
  is_bom : bool;
}

type t = {
  id : id;
  parent : id option;
  properties : Properties.t;
  depmgmt : dep Dependency.Map.t;
  deps : dep Dependency.Map.t;
}

let id_of t = t.id
let parent_of t = t.parent
let properties_of t = Properties.to_seq t.properties
let depmgmt_of t = Dependency.Map.to_seq t.depmgmt |> Seq.map (fun (_, v) -> v)
let deps_of t = Dependency.Map.to_seq t.deps |> Seq.map (fun (_, v) -> v)

let dep_of_parsed dmfn (d : Dependency.t) : dep =
  {
    classifier = Dependency.classifier_of d;
    id = Dependency.id_of dmfn d;
    exclusions = Dependency.exclusions_of d;
    optional = Dependency.is_optional d;
    scope = Dependency.scope_of d;
    tp = Dependency.tp_of d;
    is_bom = Dependency.is_bom d;
  }

let depmap_from_seq dm ps =
  ps
  |> Seq.map Dependency.unique_key
  |> Dependency.Map.of_seq
  |> Dependency.Map.map (dep_of_parsed dm)

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
  let scope = Option.value ~default:"compile" d.scope |> Option.some in
  let classifier =
    match Option.map (Properties.apply props) d.classifier with
    | Some "" -> None
    | x -> x
  in
  { d with scope; classifier }

let rec from_pom fname : t =
  let i = Inheritor.parse fname in

  let properties =
    Properties.of_id i.id
    |> Properties.merge_right i.properties
    |> Properties.resolve
  in

  let all_dm =
    depmap_from_seq (fun _ -> None) i.depmgmt
    |> Dependency.Map.map (resolve_depmap properties)
    |> Dependency.Map.to_seq
  in
  let read_bom (_, ({ id = g, a, v; _ } : dep)) =
    let p = Repo.asset_fname "pom" g a v |> from_pom in
    Dependency.Map.to_seq p.depmgmt
  in

  let non_bom =
    Seq.filter_map (fun (k, d) -> if d.is_bom then None else Some (k, d)) all_dm
  in
  let bom =
    Seq.filter_map (fun (k, d) -> if d.is_bom then Some (k, d) else None) all_dm
    |> Seq.flat_map read_bom
  in
  let depmgmt = Seq.append bom non_bom |> Dependency.Map.of_seq in

  let dmfn k =
    Dependency.Map.find_opt k depmgmt
    |> Option.map (fun ({ id = _, _, v; _ } : dep) -> v)
  in
  let deps = 
    Seq.map (normalise_dep properties) i.deps
    |> depmap_from_seq dmfn 
  in

  { id = i.id; parent = i.parent; properties; depmgmt; deps }

let from_java fname = Repo.pom_of_java fname |> from_pom
