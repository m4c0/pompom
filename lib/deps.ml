module GrpArt =
  struct
    type t = string * string
    let compare (g0, a0) (g1, a1) =
      match String.compare g0 g1 with
      | 0 -> String.compare a0 a1
      | c -> c
  end

module GAMap = Map.Make(GrpArt)

type t = string GAMap.t

type triplet = string * string * string

let merge =
  let add m (g, a, v) = GAMap.add (g, a) v m in
  List.fold_left add

let from_list (l : triplet list) : t = merge GAMap.empty l

let to_list (l : t) : triplet list =
  let fn (g, a) v l = (g, a, v) :: l in
  GAMap.fold fn l []

let find (l : t) ({ group; artifact; version } : Parser.id) : triplet =
  (* TODO: improve error if group or artifact is not defined *)
  let g = Option.get group in
  let a = Option.get artifact in
  match GAMap.find_opt (g, a) l with
  | None -> 
      let v = Option.get version in
      (g, a, v)
  | Some v -> (g, a, v)

