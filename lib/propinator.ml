module PropMap = Map.Make (String)

type t = string PropMap.t

let prop_regex = Str.regexp "\\${\\(.*\\)}"
let of_seq = PropMap.of_seq

let rec apply_to_str (props : t) (parsed : Parser.t) (s : string) : string =
  let fn pp : string =
    let p = Str.matched_group 1 pp in
    match p with
    | "project.artifactId" -> parsed.id.artifact
    | "project.version" -> Option.get parsed.id.version
    | _ -> (
        match PropMap.find_opt p props with
        | Some x -> x
        | None -> failwith (p ^ ": property not found"))
  in
  let res = Str.global_substitute prop_regex fn s in
  if res = s then res else apply_to_str props parsed res

let apply_to_dep (props : t) (p : Parser.t) (d : Pom.dep) : Pom.dep =
  let artifact = apply_to_str props p d.ga.artifact in
  let ga = { d.ga with artifact } in
  let version = Option.map (apply_to_str props p) d.version in
  { d with ga; version }
