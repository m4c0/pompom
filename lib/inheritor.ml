type id = string * string * string

type t = {
  id : id;
  parent : id option;
  properties : Properties.t;
  depmgmt : Dependency.t Seq.t;
  deps : Dependency.t Seq.t;
  modules : string Seq.t;
}

let id_of_parsed (p : Parser.t) parent =
  match parent with
  | Some (pg, _, pv) ->
      let g = Option.value p.id.group ~default:pg in
      let v = Option.value p.id.version ~default:pv in
      (g, p.id.artifact, v)
  | None ->
      if p.id.group = None then failwith "missing groupId";
      if p.id.version = None then failwith "missing version";
      let g = Option.get p.id.group in
      let v = Option.get p.id.version in
      (g, p.id.artifact, v)

let merged_props props (parent : t option) =
  let p0 = Properties.of_seq props in
  match parent with
  | None -> p0
  | Some pp -> Properties.merge_left p0 pp.properties

module Map = Map.Make(String)
let cache = ref Map.empty

let rec rparse fname =
  let p = Parser.parse_file fname in
  let parent = p.parent in
  let parent_p =
    Option.map (Repo.parent_of_pom fname) p.parent |> Option.map parse
  in
  let id = id_of_parsed p parent in
  let properties = merged_props p.props parent_p in

  let parent_dm = Option.to_seq parent_p |> Seq.flat_map (fun p -> p.depmgmt) in
  let depmgmt = Seq.append p.dep_mgmt parent_dm in

  let parent_deps = Option.to_seq parent_p |> Seq.flat_map (fun p -> p.deps) in
  let deps = Seq.append p.deps parent_deps in

  { id; parent; properties; depmgmt; deps; modules = p.modules }
and parse fname : t =
  match Map.find_opt fname !cache with
  | Some tt -> tt
  | None ->
      let tt = rparse fname in
      cache := Map.add fname tt !cache;
      tt
