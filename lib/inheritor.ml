type id = string * string * string
type t = {
  parent: id;
  id: id;
  deps: id list;
}

let to_id ((pgrp, part, pver) : id) (id : Parser.id) : id =
  let grp = Option.value id.group ~default:pgrp in
  let art = Option.value id.artifact ~default:part in
  let ver = Option.value id.version ~default:pver in
  (grp, art, ver)

let read_single_pom fname =
  let pt = Parser.parse_file fname in
  let parent = to_id ("", "", "") pt.parent in
  let id = to_id parent pt.id in
  let deps = List.map (to_id parent) pt.deps in
  { parent; id; deps }
