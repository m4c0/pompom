module PropMap = Map.Make (String)

type t = string PropMap.t

let prop_regex = Str.regexp "\\${\\([^}]*\\)}"

let rec apply (chain : t Seq.t) (s : string) : string =
  let pvalue (s : string) : string =
    let k = Str.matched_group 1 s in
    let ch = Seq.filter_map (PropMap.find_opt k) chain in
    match ch () with
    | Nil -> Errors.fail k "missing property"
    | Cons (v, _) -> v
  in
  let ns = Str.global_substitute prop_regex pvalue s in
  if ns = s then s else apply chain ns

let of_seq x = Seq.return @@ PropMap.of_seq x
let of_list x = of_seq @@ List.to_seq x

let of_id (g, a, v) =
  let gg = ("project.groupId", g) in
  let aa = ("project.artifactId", a) in
  let vv = ("project.version", v) in
  of_list [ gg; aa; vv ]

let%test _ =
  let ofid = of_id ("gg", "aa", "vv") in
  let ofsq =
    List.to_seq [ ("aa", "${project.version}"); ("bb", "${aa}") ] |> of_seq
  in
  let chain = Seq.append ofid ofsq in
  let apply = apply chain in
  apply "${aa} ${bb} ${project.groupId}" = "vv vv gg"
