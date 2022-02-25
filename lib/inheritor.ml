module PropMap = Map.Make(String)
type prop_map = string PropMap.t

type id = string * string * string
type dep = string option
type dm = string
type t = {
  id: id;
  deps: dep Ga_map.t;
  dep_mgmt: string Ga_map.t;
  boms: string Ga_map.t;
  props: prop_map; 
  modules: string list;
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

let dep_of (parent : t option) (deps : dep Ga_map.t) =
  match parent with
  | Some p -> Ga_map.merge p.deps deps
  | None -> deps

let dep_mgmt_of (parent : t option) (dm : dm Ga_map.t) =
  match parent with
  | Some p -> Ga_map.merge p.dep_mgmt dm
  | None -> dm

let bom_of (parent : t option) (boms : dm Ga_map.t) =
  match parent with
  | Some p -> Ga_map.merge p.boms boms
  | None -> boms

let props_of (parent : t option) (props : prop_map) =
  match parent with
  | Some p -> PropMap.merge Map_utils.parent_merger p.props props
  | None -> props

let m2dir = 
  [ Sys.getenv "HOME"; ".m2"; "repository" ] |>
  List.fold_left Filename.concat ""

let fname_of group artifact version =
  let fn = artifact ^ "-" ^ version ^ ".pom" in
  (String.split_on_char '.' group)
  @ [ artifact; version; fn ]
  |> List.fold_left Filename.concat m2dir

let read_pom ref_fname =
  let rec parse_parent_pom (cfn : string) (pid : Parser.parent) : t =
    let pfld = Filename.dirname cfn |> Filename.dirname in
    let pfn = Filename.concat pfld "pom.xml" in
    if pfn <> cfn && Sys.file_exists pfn
    then Parser.parse_file pfn |> stitch_pom pfn
    else
      let { group; artifact; version } : Parser.parent = pid in
      let repofn = fname_of group artifact version in
      Parser.parse_file repofn |> stitch_pom repofn
  and stitch_pom (fname : string) (parsed : Parser.t) : t =
    let parent = Option.map (parse_parent_pom fname) parsed.parent in

    let id : id = id_of parent parsed.id in

    let is_bom ({ scope; tp; _ } : Parser.dm) = scope = Some("import") && tp = Some("pom") in
    let dm_fn ({ group; artifact; version; _ } : Parser.dm) = ((group, artifact), version) in
    let dep_mgmt = 
      List.filter (Fun.negate is_bom) parsed.dep_mgmt |>
      Ga_map.from_list dm_fn |>
      dep_mgmt_of parent
    in
    let boms = 
      List.filter is_bom parsed.dep_mgmt |>
      Ga_map.from_list dm_fn |>
      bom_of parent
    in

    let dp_fn ({ group; artifact; version } : Parser.dep) = ((group, artifact), version) in
    let deps = Ga_map.from_list dp_fn parsed.deps |> dep_of parent in

    let props = List.to_seq parsed.props |> PropMap.of_seq |> props_of parent in

    let modules = parsed.modules in

    { id; deps; dep_mgmt; boms; props; modules }
  in
  Parser.parse_file ref_fname |> stitch_pom ref_fname

let read_pom_of_id grp art ver = fname_of grp art ver |> read_pom

