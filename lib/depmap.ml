module Map = Map.Make (struct
  type t = string * string * string option * string option

  let compare (ga, aa, ta, ca) (gb, ab, tb, cb) =
    let copt x y =
      match (x, y) with
      | None, None -> 0
      | Some xx, Some yy -> String.compare xx yy
      | None, Some _ -> -1
      | Some _, None -> 1
    in
    match String.compare ga gb with
    | 0 -> (
        match String.compare aa ab with
        | 0 -> ( match copt ta tb with 0 -> copt ca cb | x -> x)
        | x -> x)
    | x -> x
end)

type 'a t = 'a Map.t

let empty = Map.empty
let find_opt = Map.find_opt
let map = Map.map
let of_seq = Map.of_seq
let to_seq = Map.to_seq
