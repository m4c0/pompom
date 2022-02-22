let resolve (dm : string Ga_map.t) (deps : string option Ga_map.t) : string Ga_map.t =
  let fn (g, a) (v : string option) =
    match v with
    | Some x -> x
    | None ->
        match Ga_map.find_opt (g, a) dm with
        | Some x -> x
        | None -> Printf.sprintf "missing version for %s:%s" g a |> failwith
  in
  Ga_map.mapi fn deps

