type id = {
  group: string option;
  artifact: string option;
  version: string option;
}
type t = {
  parent: id;
  id: id;
  deps: id list;
}

let empty_id : id = {
  group = None;
  artifact = None;
  version = None;
}
let empty : t = {
  parent = empty_id;
  id = empty_id;
  deps = [];
}

let text_of (l : Xmelly.t list) : string option =
  match l with
  | [Text t] -> Some(t)
  | _ -> None

let rec id_of (l : Xmelly.t list) : id =
  match l with
  | [] -> empty_id
  | Element("groupId", _, el) :: ll ->
      { (id_of ll) with group = (text_of el) }
  | Element("artifactId", _, el) :: ll ->
      { (id_of ll) with artifact = (text_of el) }
  | Element("version", _, el) :: ll ->
      { (id_of ll) with version = (text_of el) }
  | _ :: ll -> id_of ll

let deps_of (l : Xmelly.t list) : id list =
  let dep_of (xml : Xmelly.t) =
    match xml with
    | Element("dependency", _, el) -> id_of el
    | _ -> failwith "unexpected thing inside dependencies"
  in
  l |> List.map dep_of

let rec project_of (l : Xmelly.t list) : t =
  match l with
  | [] -> empty
  | Element("parent", _, el) :: ll ->
      { (project_of ll) with parent = (id_of el) }
  | Element("groupId", _, el) :: ll ->
      let res = project_of ll in
      { res with id = { res.id with group = (text_of el) } }
  | Element("artifactId", _, el) :: ll ->
      let res = project_of ll in
      { res with id = { res.id with artifact = (text_of el) } }
  | Element("version", _, el) :: ll ->
      let res = project_of ll in
      { res with id = { res.id with version = (text_of el) } }
  | Element("dependencies", _, el) :: ll ->
      { (project_of ll) with deps = (deps_of el) }
  | _ :: ll -> project_of ll

let from_smelly (xml : Xmelly.t) =
  match xml with
  | Element("project", _, l) -> project_of l
  | _ -> failwith "expecting 'project' as root node"

let parse_file pomfn =
  let pom = open_in pomfn in
  let res = Xmelly.parse pom |> from_smelly in
  close_in pom;
  res
