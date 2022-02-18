type id = {
  group: string;
  artifact: string;
  version: string;
}
type t = {
  parent: id;
  id: id;
  deps: id list;
}

let empty_id : id = {
  group = "";
  artifact = "";
  version = "";
}
let empty : t = {
  parent = empty_id;
  id = empty_id;
  deps = [];
}

let text_of (l : Xmelly.t list) : string =
  match l with
  | [Text t] -> t
  | _ -> failwith "element unexpected"

let rec parent_of (l : Xmelly.t list) : id =
  match l with
  | [] -> empty_id
  | Element("groupId", _, gl) :: ll ->
      let group = text_of gl in
      let res = parent_of ll in
      { res with group }
  | Element("artifactId", _, al) :: ll ->
      let artifact = text_of al in
      let res = parent_of ll in
      { res with artifact }
  | Element("version", _, vl) :: ll ->
      let version = text_of vl in
      let res = parent_of ll in
      { res with version }
  | _ :: ll -> parent_of ll

let rec project_of (l : Xmelly.t list) : t =
  match l with
  | [] -> empty
  | Element("parent", _, pl) :: ll ->
      let parent = parent_of pl in
      let res = project_of ll in
      { res with parent }
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
