module Map = Map.Make (struct
  type t = string * string * string * string option

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
        | 0 -> ( match String.compare ta tb with 0 -> copt ca cb | x -> x)
        | x -> x)
    | x -> x
end)

type 'a t = { map : 'a Map.t; order : Map.key Seq.t }

let empty = { map = Map.empty; order = Seq.empty }
let find_opt k (tt : 'a t) = Map.find_opt k tt.map
let map fn (tt : 'a t) = { tt with map = Map.map fn tt.map }

let add k v m =
  match find_opt k m with
  | Some _ -> m
  | None ->
      { map = Map.add k v m.map; order = Seq.append m.order (Seq.return k) }

let of_seq seq =
  let aux (accm, accl) (k, v) =
    match Map.find_opt k accm with
    | Some _ -> (accm, accl)
    | None -> (Map.add k v accm, k :: accl)
  in
  let map, l = Seq.fold_left aux (Map.empty, []) seq in
  { map; order = List.rev l |> List.to_seq }

let to_seq (tt : 'a t) = Seq.map (fun k -> (k, Map.find k tt.map)) tt.order

let%test "adds and retrieves" =
  let k1 = ("a", "a", "?", None) in
  let k2 = ("b", "a", "?", None) in
  let map = empty |> add k1 99 in
  find_opt k1 map = Some 99 && find_opt k2 map = None

let%test "creates from seq" =
  let k1 = ("a", "a", "?", None) in
  let k2 = ("b", "a", "?", None) in
  let map = Seq.return (k1, 99) |> of_seq in
  find_opt k1 map = Some 99 && find_opt k2 map = None

let%test "maintains order" =
  let k1 = ("a", "a", "?", None) in
  let k2 = ("b", "b", "?", None) in
  let k3 = ("c", "c", "?", None) in
  let order = [ k3; k2; k1 ] |> List.map (fun f -> (f, 99)) in
  let after =
    order |> List.to_seq |> of_seq |> map Fun.id |> to_seq |> List.of_seq
  in
  List.equal (fun a b -> a = b) order after

let%test "remove duplicates" =
  let k1 = ("a", "a", "?", None) in
  let k2 = ("b", "b", "?", None) in
  let expected = [ k2; k1 ] |> List.map (fun f -> (f, 99)) in
  let order = List.append expected expected in
  let after =
    order |> List.to_seq |> of_seq |> map Fun.id |> to_seq |> List.of_seq
  in
  List.equal (fun a b -> a = b) expected after

let%test "doesnt add duplicates" =
  let k1 = ("a", "a", "?", None) in
  let k2 = ("b", "b", "?", None) in
  empty |> add k1 0 |> add k1 0 |> add k2 0 |> add k2 0 |> to_seq |> List.of_seq
  |> List.equal (fun a b -> a = b) [ (k1, 0); (k2, 0) ]
