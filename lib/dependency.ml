type ga = { group : string; artifact : string }

type t = {
  ga : ga;
  version : string option;
  scope : string option;
  tp : string option;
  exclusions : ga Seq.t;
}

let id_of (tt : t) = (tt.ga.group, tt.ga.artifact, tt.version)
let version_of (tt : t) = tt.version

let is_bom (tt : t) = tt.scope = Some("import") && tt.tp = Some("pom")

module Map = Map.Make (struct
  type t = ga

  let compare (a : t) (b : t) =
    match String.compare a.group b.group with
    | 0 -> String.compare a.artifact b.artifact
    | x -> x
end)

type map = t Map.t

let map_of_seq (seq : t Seq.t) =
  Seq.map (fun (tt : t) -> (tt.ga, tt)) seq |> Map.of_seq

let seq_of_map (m : map) = Map.to_seq m |> Seq.map (fun (_, v) -> v)
