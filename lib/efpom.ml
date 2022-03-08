type t = {
  id : Pom.id;
  parent : Pom.id option;
}

let id_of t = t.id
let parent_of t = t.parent

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

let from_pom fname : t = 
  let p = Parser.parse_file fname in
  let parent = p.parent in
  let id = id_of_parsed p parent in
  { id; parent }

let from_java fname = Repo.pom_of_java fname |> from_pom
