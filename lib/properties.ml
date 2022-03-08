module PropMap = Map.Make (String)

type t = string PropMap.t

let prop_regex = Str.regexp "\\${\\([^}]*\\)}"

let rec apply (chain : t) (s : string) : string =
  let pvalue (s : string) : string =
    let k = Str.matched_group 1 s in
    let ch = PropMap.find_opt k chain in
    match ch with
    | None -> Errors.fail k "missing property"
    | Some v -> v
  in
  let ns = Str.global_substitute prop_regex pvalue s in
  if ns = s then s else apply chain ns

let add_seq = PropMap.add_seq
let of_seq = PropMap.of_seq
let to_seq = PropMap.to_seq

let rec resolve t =
  let next = PropMap.map (apply t) t in
  if next = t then t else resolve next

let of_id (g, a, v) =
  let gg = ("project.groupId", g) in
  let aa = ("project.artifactId", a) in
  let vv = ("project.version", v) in
  List.to_seq [ gg; aa; vv ] |> PropMap.of_seq

let%test _ =
  let seq = List.to_seq [ ("aa", "vv"); ( "bb", "${aa}" ) ] in
  let applier = of_id ("gg", "aa", "vv") |> add_seq seq |> apply in
  applier "${aa} ${bb} ${project.groupId}" = "vv vv gg"
