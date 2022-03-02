module PropMap = Map.Make (String)

type dep = Parser.dep_data
type prop_map = string PropMap.t
type dep_map = dep Ga_map.t

type t = {
  id : Pom.id;
  deps : dep_map;
  dep_mgmt : dep_map;
  props : prop_map;
  modules : string list;
}

let id_of (parent : t option) (pid : Parser.id) : Pom.id =
  let value fld fn = function
    | Some v -> v
    | None -> (
        match parent with
        | Some p -> fn p.id
        | None -> "missing " ^ fld |> failwith)
  in
  let group = value "groupId" (fun p -> p.ga.group) pid.group in
  let artifact = pid.artifact in
  let version = value "version" (fun p -> p.version) pid.version in
  { ga = { group; artifact }; version }

let merge_parent_map (parent : t option) mapfn map =
  match parent with Some p -> Ga_map.merge (mapfn p) map | None -> map

let props_of (parent : t option) (props : prop_map) =
  match parent with
  | Some p -> PropMap.merge Map_utils.parent_merger p.props props
  | None -> props

(**
   Read and merge the POM hiearchy into a single POM.
   Given a parseable file, it dives into its <parent> hiearchy to merge its
   properties into a single structure
*)
let read_pom (ref_fname : string) : t =
  let rec parse_parent_pom (cfn : string) (pid : Parser.parent) : t =
    let ({ group; artifact; version } : Parser.parent) = pid in
    let repofn = Repo.parent_of_pom cfn group artifact version in
    Parser.parse_file repofn |> stitch_pom repofn
  and stitch_pom (fname : string) (parsed : Parser.t) : t =
    let parent = Option.map (parse_parent_pom fname) parsed.parent in

    let id : Pom.id = id_of parent parsed.id in

    let dp_fn (d : Parser.dep) = ((d.ga.group, d.ga.artifact), d.data) in

    let dep_mgmt =
      Seq.map dp_fn parsed.dep_mgmt
      |> Ga_map.of_seq
      |> merge_parent_map parent (fun p -> p.dep_mgmt)
    in

    let deps =
      Seq.map dp_fn parsed.deps |> Ga_map.of_seq
      |> merge_parent_map parent (fun p -> p.deps)
    in

    let props = PropMap.of_seq parsed.props |> props_of parent in

    let modules = List.of_seq parsed.modules in

    { id; deps; dep_mgmt; props; modules }
  in
  Parser.parse_file ref_fname |> stitch_pom ref_fname
