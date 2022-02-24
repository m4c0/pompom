type t = {
  id : string * string * string;
  deps : string Ga_map.t;
}

let deps_seq (tt : t) : (string * string * string) Seq.t =
  Ga_map.to_seq tt.deps
  |> Seq.map (fun ((g, a), v) -> (g, a, v))

let from_java m2dir fname =
  let rec pom_of fname = 
    let pom = Filename.concat fname "pom.xml" in
    if Sys.file_exists pom
    then pom
    else fname |> Filename.dirname |> pom_of
  in
  let (id, deps) = pom_of fname |> Deps.resolve m2dir in
  { id; deps }

