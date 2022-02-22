type id = string * string * string
type t = {
  id: id;
  deps: string option Ga_map.t;
  dep_mgmt: string Ga_map.t;
}

let id_of (parent : t option) (pid : Parser.id) =
  match parent with
  | Some p ->
      let (g, _, v) = p.id in
      let group = Option.value ~default:g pid.group in
      let artifact = pid.artifact in
      let version = Option.value ~default:v pid.version in
      (group, artifact, version)
  | None ->
      let get_or_fail fld = function
        | Some x -> x
        | None -> "missing " ^ fld |> failwith
      in
      let group = get_or_fail "groupId" pid.group in
      let artifact = pid.artifact in
      let version = get_or_fail "version" pid.version in
      (group, artifact, version)

let dep_of (parent : t option) (deps : string option Ga_map.t) =
  match parent with
  | Some p -> Ga_map.merge p.deps deps
  | None -> deps

let read_pom (m2dir : string) ref_fname =
  let rec parse_parent_pom (cfn : string) (pid : Parser.parent) : t =
    let pfld = Filename.dirname cfn |> Filename.dirname in
    let pfn = Filename.concat pfld "pom.xml" in
    if pfn <> cfn && Sys.file_exists pfn
    then Parser.parse_file pfn |> stitch_pom pfn
    else
      let { group; artifact; version } : Parser.parent = pid in
      let fn = artifact ^ "-" ^ version ^ ".pom" in
      let repofn =
        (String.split_on_char '.' group)
        @ [ artifact; version; fn ]
        |> List.fold_left Filename.concat m2dir
      in
      Parser.parse_file repofn |> stitch_pom repofn
  and stitch_pom (fname : string) (parsed : Parser.t) : t =
    let parent = Option.map (parse_parent_pom fname) parsed.parent in

    let id : id = id_of parent parsed.id in

    let dm_fn ({ group; artifact; version } : Parser.dm) = ((group, artifact), version) in
    let dep_mgmt = Ga_map.from_list dm_fn parsed.dep_mgmt in

    let dp_fn ({ group; artifact; version } : Parser.dep) = ((group, artifact), version) in
    let deps = Ga_map.from_list dp_fn parsed.deps |> dep_of parent in

    { id; deps; dep_mgmt }
  in
  Parser.parse_file ref_fname |> stitch_pom ref_fname
