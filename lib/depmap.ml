module Map = Map.Make (struct
  type t = string * string

  let compare (ga, aa) (gb, ab) =
    match String.compare ga gb with 0 -> String.compare aa ab | x -> x
end)

type 'a t = 'a Map.t

let merge_left (a : 'x t) (b : 'x t) =
  Map.merge (fun _ a b -> match a with None -> b | _ -> a) a b

let merge_right (a : 'x t) (b : 'x t) =
  Map.merge (fun _ a b -> match b with None -> a | _ -> b) a b

let of_seq (seq : (string * string * 'a) Seq.t) =
  Seq.map (fun (g, a, v) -> ((g, a), v)) seq |> Map.of_seq

let to_seq (tt : 'a t) = Map.to_seq tt |> Seq.map (fun ((g, a), v) -> (g, a, v))
