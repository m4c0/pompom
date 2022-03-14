module Set = Set.Make (struct
  type t = string * string

  let compare (ga, aa) (gb, ab) =
    match String.compare ga gb with 0 -> String.compare aa ab | x -> x
end)

type t = Set.t

let add_seq = Set.add_seq
let of_seq = Set.of_seq

let accepts tt d =
  let g, a, _ = Efdep.id_of d in
  Set.find_opt (g, a) tt |> Option.is_none
