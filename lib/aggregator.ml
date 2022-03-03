type t = {
  id : string * string * string;
  deps : Parser.dep_data Ga_map.t;
  dep_mgmt : Parser.dep_data Ga_map.t;
  props : Propinator.t;
  modules : string list;
}

(** Transforms a "inherited" POM into a map-based structure *)
let read_pom (ref_fname : string) : t =
  let ga_seq_split ({ ga; data } : Parser.dep) = (ga, data) in

  let p = Inheritor.parse_and_merge ref_fname in

  let group = Option.get p.id.group in
  let artifact = p.id.artifact in
  let version = Option.get p.id.version in

  let id = (group, artifact, version) in
  let deps = Seq.map ga_seq_split p.deps |> Ga_map.of_seq in
  let dep_mgmt = Seq.map ga_seq_split p.dep_mgmt |> Ga_map.of_seq in
  let modules = p.modules |> List.of_seq in
  let props = Propinator.of_seq p.props in

  { id; deps; dep_mgmt; modules; props }
