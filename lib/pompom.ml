type t = Inheritor.t

let from_java fname =
  let rec pom_of fname = 
    let pom = Filename.concat fname "pom.xml" in
    if Sys.file_exists pom
    then pom
    else fname |> Filename.dirname |> pom_of
  in
  pom_of fname |> Inheritor.read_single_pom
