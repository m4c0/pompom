module Map = Map.Make (struct
  type t = string * string

  let compare (ga, aa) (gb, ab) =
    match String.compare ga gb with 0 -> String.compare aa ab | x -> x
end)

type 'a t = 'a Map.t

let of_seq (seq : (string * string * 'a) Seq.t) =
  let fn m (g, a, v) =
    match Map.find_opt (g, a) m with Some _ -> m | None -> Map.add (g, a) v m
  in
  Seq.fold_left fn Map.empty seq

let to_seq (tt : 'a t) = Map.to_seq tt |> Seq.map (fun ((g, a), v) -> (g, a, v))
let find_opt (d : Dependency.t) (tt : 'a t) = Map.find_opt (d.ga.group, d.ga.artifact) tt 
let exists (d : Dependency.t) (tt : 'a t) = find_opt d tt |> Option.is_some
