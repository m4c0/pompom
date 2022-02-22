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
  let i = pom_of fname |> Inheritor.read_pom m2dir in
  let fmap _ (dm : Inheritor.dm) = if dm.is_bom then None else Some dm.version in
  let dm = Ga_map.filter_map fmap i.dep_mgmt in
  let deps = Deps.resolve dm i.deps in
  { id = i.id; deps }

