type id = string * string * string
type t = {
  parent: id;
  id: id;
  deps: id list;
}

let from_java fname =
  let rec pom_of fname = 
    let pom = Filename.concat fname "pom.xml" in
    if Sys.file_exists pom
    then pom
    else fname |> Filename.dirname |> pom_of
  in
  let to_id ((pgrp, part, pver) : id) (id : Parser.id) : id =
    let grp = Option.value id.group ~default:pgrp in
    let art = Option.value id.artifact ~default:part in
    let ver = Option.value id.version ~default:pver in
    (grp, art, ver)
  in
  let pt = pom_of fname |> Parser.parse_file in
  let parent = to_id ("", "", "") pt.parent in
  let id = to_id parent pt.id in
  let deps = List.map (to_id parent) pt.deps in
  { parent; id; deps }
