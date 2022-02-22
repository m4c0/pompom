module GrpArt =
  struct
    type t = string * string
    let compare (g0, a0) (g1, a1) =
      match String.compare g0 g1 with
      | 0 -> String.compare a0 a1
      | c -> c
  end

module GAMap = Map.Make(GrpArt)

type 'a t = 'a GAMap.t

let from_list fn l =
  let f acc x = 
    let (key, data) = fn x in
    GAMap.add key data acc
  in 
  List.fold_left f GAMap.empty l

let merge am bm =
  let fn _ a b = 
    match (a, b) with
    | None, None -> None
    | Some aa, None -> Some aa
    | None, Some bb -> Some bb
    | Some _, Some bb -> Some bb
  in
  GAMap.merge fn am bm

let find_opt = GAMap.find_opt
let iter = GAMap.iter
let mapi = GAMap.mapi
