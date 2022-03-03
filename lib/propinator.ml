module PropMap = Map.Make (String)

type t = string PropMap.t

let prop_regex = Str.regexp "\\${\\(.*\\)}"
let of_seq = PropMap.of_seq

let rec apply_to_str (props : t) (s : string) : string =
  let fn pp =
    let p = Str.matched_group 1 pp in
    match PropMap.find_opt p props with
    | Some x -> x
    | None -> failwith (p ^ ": property not found")
  in
  let res = Str.global_substitute prop_regex fn s in
  if res = s then res else apply_to_str props res

let apply_to_dep (props : t) (d : Pom.dep) : Pom.dep =
  { d with version = Option.map (apply_to_str props) d.version }
