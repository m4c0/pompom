type t = string * string * string

let group_of (tt : t option) = Option.map (fun (g, _, _) -> g) tt
let version_of (tt : t option) = Option.map (fun (_, _, v) -> v) tt
