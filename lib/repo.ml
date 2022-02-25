let m2dir = 
  [ Sys.getenv "HOME"; ".m2"; "repository" ] |>
  List.fold_left Filename.concat ""

let asset_fname ext group artifact version =
  let fn = artifact ^ "-" ^ version ^ "." ^ ext in
  (String.split_on_char '.' group)
  @ [ artifact; version; fn ]
  |> List.fold_left Filename.concat m2dir
