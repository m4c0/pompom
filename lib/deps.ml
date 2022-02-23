type id = string * string * string
type bom = string Ga_map.t

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

let resolve m2dir pom_fname : id * bom =
  let i = Inheritor.read_pom m2dir pom_fname in
  let deps = merge_deps i.dep_mgmt i.deps in
  (i.id, deps)
