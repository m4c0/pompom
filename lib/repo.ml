let m2dir =
  [ Sys.getenv "HOME"; ".m2"; "repository" ]
  |> List.fold_left Filename.concat ""

let asset_fname ext group artifact version =
  let fn = artifact ^ "-" ^ version ^ "." ^ ext in
  String.split_on_char '.' group @ [ artifact; version; fn ]
  |> List.fold_left Filename.concat m2dir

let parent_of_pom child_fname parent_g parent_a parent_v =
  let pfld = Filename.dirname child_fname |> Filename.dirname in
  let pfn = Filename.concat pfld "pom.xml" in
  if pfn <> child_fname && Sys.file_exists pfn then pfn
  else asset_fname "pom" parent_g parent_a parent_v

let rec pom_of_java fname =
  let pom = Filename.concat fname "pom.xml" in
  if Sys.file_exists pom then pom
  else
    let next_fname = Filename.dirname fname in
    if next_fname = fname then failwith "could not find POM"
    else pom_of_java next_fname
