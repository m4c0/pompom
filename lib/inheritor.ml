type id = string * string * string
type t = {
  parent: t option;
  id: id;
  deps: id list;
}

let to_id ((pgrp, part, pver) : id) (id : Parser.id) : id =
  let grp = Option.value id.group ~default:pgrp in
  let art = Option.value id.artifact ~default:part in
  let ver = Option.value id.version ~default:pver in
  (grp, art, ver)

let id_or_bust tp (pid : Parser.id) =
  let get_or_fail fld = function 
    | None -> Printf.sprintf "%s %s is not defined" tp fld |> failwith
    | Some x -> x
  in
  let grp = get_or_fail "groupId" pid.group in
  let art = get_or_fail "artifact" pid.artifact in
  let ver = get_or_fail "version" pid.version in
  (grp, art, ver)

let is_empty (id : Parser.id) =
  Option.is_none id.group && Option.is_none id.artifact && Option.is_none id.version

let read_pom (m2dir : string) fname =
  let parse_parent_pom (pid : Parser.id) (cfn : string) : string * Parser.t =
    let pfld = Filename.dirname cfn |> Filename.dirname in
    let pfn = Filename.concat pfld "pom.xml" in
    if pfn <> cfn && Sys.file_exists pfn
    then (pfn, Parser.parse_file pfn)
    else
      let (grp, art, ver) = id_or_bust "parent" pid in
      let fn = art ^ "-" ^ ver ^ ".pom" in
      let repofn =
        (String.split_on_char '.' grp)
        @ [ art; ver; fn ]
        |> List.fold_left Filename.concat m2dir
      in
      (repofn, Parser.parse_file repofn)
  in
  let rec stitch_pom (fname : string) (parsed : Parser.t) : t =
    if is_empty parsed.parent
    then
      let parent = None in
      let id = id_or_bust "orphan pom" parsed.id in
      let deps = List.map (id_or_bust "orphan pom's dependency") parsed.deps in
      { parent; id; deps }
    else
      let (pfn, pp) = parse_parent_pom parsed.parent fname in
      let parent = stitch_pom pfn pp in
      let id = to_id parent.id parsed.id in
      let deps = List.map (to_id id) parsed.deps in
      { parent = Some(parent); id; deps }
  in
  Parser.parse_file fname |> stitch_pom fname
