type t = {
  id : string * string * string;
  deps : string Ga_map.t;
  modules : string list;
}

(** Transforms a "inherited" POM into a map-based structure *)
let aggregate (p : Parser.t) : t =
  let group = Option.get p.id.group in
  let artifact = p.id.artifact in
  let version = Option.get p.id.version in

  let id = (group, artifact, version) in
  let modules = p.modules |> List.of_seq in

  let ga_seq_split (d : Pom.dep) = (d.ga, Option.get d.version) in
  let ga_mapinate (l : Pom.dep Seq.t) : string Ga_map.t =
    Seq.map ga_seq_split l |> Ga_map.of_seq
  in
  let deps = ga_mapinate p.deps in

  { id; deps; modules }
