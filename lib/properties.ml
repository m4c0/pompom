module PropMap = Map.Make (String)

type t = string PropMap.t

let prop_regex = Str.regexp "\\${\\([^}]*\\)}"

let rec apply (chain : t) (s : string) : string =
  let pvalue (s : string) : string =
    let k = Str.matched_group 1 s in
    let ch = PropMap.find_opt k chain in
    match ch with None -> Str.matched_group 0 s | Some v -> v
  in
  let ns = Str.global_substitute prop_regex pvalue s in
  if ns = s then s else apply chain ns

let merge_left = PropMap.merge (fun _ a b -> match a with None -> b | _ -> a)
let merge_right = PropMap.merge (fun _ a b -> match b with None -> a | _ -> b)
let of_seq = PropMap.of_seq
let to_seq = PropMap.to_seq

let rec resolve t =
  let next = PropMap.map (apply t) t in
  if next = t then t else resolve next

let of_id (g, a, v) =
  PropMap.empty
  |> PropMap.add "project.groupId" g
  |> PropMap.add "project.artifactId" a
  |> PropMap.add "project.version" v

let add_parent_id p (g, a, v) =
  p
  |> PropMap.add "project.parent.groupId" g
  |> PropMap.add "project.parent.artifactId" a
  |> PropMap.add "project.parent.version" v

let%test _ =
  let seq = List.to_seq [ ("aa", "vv"); ("bb", "${aa}") ] |> of_seq in
  let applier = of_id ("gg", "aa", "vv") |> merge_left seq |> apply in
  applier "${aa} ${bb} ${project.groupId}" = "vv vv gg"
