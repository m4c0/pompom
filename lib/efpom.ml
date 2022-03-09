type id = string * string * string
type t = { id : id; parent : id option; properties : Properties.t; depmgmt : Depmgmt.t }

let id_of t = t.id
let parent_of t = t.parent
let properties_of t = Properties.to_seq t.properties
let depmgmt_of t = Depmgmt.to_seq t.depmgmt

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

let rec inheritor fname : t =
  let p = Parser.parse_file fname in
  let parent = p.parent in
  let parent_p =
    Option.map (Repo.parent_of_pom fname) p.parent |> Option.map inheritor
  in
  let id = id_of_parsed p parent in
  let properties = merged_props p.props parent_p in
  let depmgmt = Depmgmt.of_dep_seq Seq.empty in
  { id; parent; properties; depmgmt }

let from_pom fname : t =
  let i = inheritor fname in
  let properties =
    Properties.of_id i.id
    |> Properties.merge_right i.properties
    |> Properties.resolve
  in
  { i with properties }

let from_java fname = Repo.pom_of_java fname |> from_pom
