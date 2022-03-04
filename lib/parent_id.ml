type t = string * string * string

let group_fn (tt : t option) () = Option.map (fun (g, _, _) -> g) tt
let version_fn (tt : t option) () = Option.map (fun (_, _, v) -> v) tt
