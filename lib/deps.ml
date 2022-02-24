type id = string * string * string
type bom = string Ga_map.t

let prop_regex = Str.regexp "\\${\\(.*\\)}"
let rec apply_props (i : Inheritor.t) (s : string) : string =
  let fn pp =
    let p = Str.matched_group 1 pp in
    match Inheritor.PropMap.find_opt p i.props with
    | Some x -> x
    | None -> failwith (p ^ ": property not found")
  in
  let res = Str.global_substitute prop_regex fn s in
  if res = s then res else apply_props i res

let merge_deps (dm : bom) (deps : string option Ga_map.t) : bom =
  let fn (g, a) (v : string option) =
    match v with
    | Some x -> x
    | None ->
        match Ga_map.find_opt (g, a) dm with
        | Some x -> x
        | None -> Printf.sprintf "missing version for %s:%s" g a |> failwith
  in
  Ga_map.mapi fn deps

let rec merge_tree (m2dir : string) (i : Inheritor.t) =
  let read_merge ((g, a), v) =
    apply_props i v |>
    Inheritor.read_pom_of_id m2dir g a |>
    merge_tree m2dir
  in
  let folder (acc : Inheritor.t) (i : Inheritor.t) =
    let deps = Ga_map.merge acc.deps i.deps in
    let dep_mgmt = Ga_map.merge acc.dep_mgmt i.dep_mgmt in
    let boms = Ga_map.merge acc.boms i.boms in
    { acc with deps; dep_mgmt; boms }
  in
  Ga_map.to_seq i.boms |>
  Seq.map read_merge |>
  Seq.fold_left folder i

let dep_from (dm : bom) (g, a) = function
  | Some x -> x
  | None -> 
      match Ga_map.find_opt (g, a) dm with
      | Some x -> x
      | None -> "could not find version for " ^ g ^ ":" ^ a |> failwith

let dep_with_prop_from (i : Inheritor.t) k v : string =
  dep_from i.dep_mgmt k v |>
  apply_props i

let resolve m2dir pom_fname : id * bom =
  let i = Inheritor.read_pom m2dir pom_fname |> merge_tree m2dir in
  let deps = Ga_map.mapi (dep_with_prop_from i) i.deps in
  (i.id, deps)
