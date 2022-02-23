type t = {
  id : string * string * string;
  deps : string Ga_map.t;
}

let iter_deps fn (tt : t) =
  Ga_map.iter fn tt.deps

let from_java m2dir fname =
  let rec pom_of fname = 
    let pom = Filename.concat fname "pom.xml" in
    if Sys.file_exists pom
    then pom
    else fname |> Filename.dirname |> pom_of
  in
  let (id, deps) = pom_of fname |> Deps.resolve m2dir in
  { id; deps }

