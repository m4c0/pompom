type t = Inheritor.t

let iter_deps fn (tt : t) =
  let f k v = fn k (Option.value ~default:"" v) in
  Ga_map.iter f tt.deps

let from_java m2dir fname =
  let rec pom_of fname = 
    let pom = Filename.concat fname "pom.xml" in
    if Sys.file_exists pom
    then pom
    else fname |> Filename.dirname |> pom_of
  in
  pom_of fname |> Inheritor.read_pom m2dir
