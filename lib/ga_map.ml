module GrpArt = struct
  type t = Pom.ga

  let compare (a : t) (b : t) =
    match String.compare a.group b.group with
    | 0 -> String.compare a.artifact b.artifact
    | c -> c
end

module GAMap = Map.Make (GrpArt)

type 'a t = 'a GAMap.t

let find_opt = GAMap.find_opt
let of_seq = GAMap.of_seq
let to_seq = GAMap.to_seq
