type t = {
  id : string * string * string;
  deps : Pom.dep Ga_map.t;
  dep_mgmt : Pom.dep Ga_map.t;
  props : Propinator.t;
  modules : string list;
}

(** Transforms a "inherited" POM into a map-based structure *)
let read_pom (p : Parser.t) : t =
  let group = Option.get p.id.group in
  let artifact = p.id.artifact in
  let version = Option.get p.id.version in

  let id = (group, artifact, version) in
  let modules = p.modules |> List.of_seq in
  let props = Propinator.of_seq p.props in

  let ga_seq_split (d : Pom.dep) = (d.ga, d) in
  let ga_mapinate (l : Pom.dep Seq.t) : Pom.dep Ga_map.t =
    Seq.map (Propinator.apply_to_dep props) l
    |> Seq.flat_map Boomer.merge_boms
    |> Seq.map ga_seq_split |> Ga_map.of_seq
  in
  let deps = ga_mapinate p.deps in
  let dep_mgmt = ga_mapinate p.dep_mgmt in

  { id; deps; dep_mgmt; modules; props }
