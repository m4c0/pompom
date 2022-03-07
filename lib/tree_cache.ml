module Map = Map.Make (String)

type 'a t = 'a Map.t ref

let empty () = ref Map.empty

let retrieve k fn (m : 'a t) : 'a =
  match Map.find_opt k !m with
  | Some x -> x
  | None ->
      let res = fn k in
      m := Map.add k (fn k) !m;
      res
