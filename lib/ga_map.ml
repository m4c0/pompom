module GrpArt = struct
  type t = Pom.ga

  let compare (a : t) (b : t) =
    match String.compare a.group b.group with
    | 0 -> String.compare a.artifact b.artifact
    | c -> c
end

module GAMap = Map.Make (GrpArt)

type 'a t = 'a GAMap.t

let from_list fn l =
  let f acc x =
    let key, data = fn x in
    GAMap.add key data acc
  in
  List.fold_left f GAMap.empty l

let merge am bm = GAMap.merge Map_utils.parent_merger am bm
let add_seq = GAMap.add_seq
let filter_map = GAMap.filter_map
let find_opt = GAMap.find_opt
let iter = GAMap.iter
let mapi = GAMap.mapi
let of_seq = GAMap.of_seq
let to_seq = GAMap.to_seq
