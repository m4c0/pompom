type node = Dependency.t
type t = node Depmap.t

let of_dep_seq (s : Dependency.t Seq.t) =
  s
  |> Seq.map (fun (d : Dependency.t) -> (d.ga.group, d.ga.artifact, d))
  |> Depmap.of_seq

let find (d : Dependency.t) (tt : t) = Depmap.find_opt d tt |> Option.to_seq
let exclusions_of (n : node) = n.exclusions
let version_of (n : node) = Option.to_seq n.version
let optional_of (n : node) = Option.to_seq n.optional
