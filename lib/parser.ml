type id = {
  group: string option;
  artifact: string;
  version: string option;
}
type dep = {
  group: string;
  artifact: string;
  version: string option;
  scope: string option;
}
type dm = {
  group: string;
  artifact: string;
  version: string;
  scope: string option;
  tp: string option;
}
type parent = {
  group: string;
  artifact: string;
  version: string;
}
type prop = string * string

type t = {
  parent: parent option;
  id: id;
  deps: dep list;
  dep_mgmt: dm list;
  props: prop list;
  modules: string list;
}

let find_element (t : string) (l : Xmelly.t list) : Xmelly.t list option =
  let fn : Xmelly.t -> Xmelly.t list option  = function
    | Element(x, _, xs) when x = t -> Some xs
    | _ -> None
  in
  List.find_map fn l

let find_text (t : string) (l : Xmelly.t list) : string option =
  let fn : Xmelly.t -> string option  = function
    | Element(x, _, [Text tt]) when x = t -> Some tt
    | _ -> None
  in
  List.find_map fn l

let get_or_fail msg = function
  | Some x -> x
  | None -> failwith msg

let dep_of : Xmelly.t -> dep = function
  | Element("dependency", _, l) -> 
      let find f = find_text f l |> get_or_fail (f ^ " is not set in dependency") in
      let group = find "groupId" in
      let artifact = find "artifactId" in
      let version = find_text "version" l in
      let scope = find_text "scope" l in
      { group; artifact; version; scope }
  | _ -> failwith "found weird stuff inside dependencies"

let dep_mgmt_of : Xmelly.t -> dm = function
  | Element("dependency", _, l) -> 
      let find f = find_text f l |> get_or_fail (f ^ " is not set in dependency management") in
      let group = find "groupId" in
      let artifact = find "artifactId" in
      let version = find "version" in
      let scope = find_text "scope" l in
      let tp = find_text "type" l in
      { group; artifact; version; scope; tp  }
  | _ -> failwith "found weird stuff inside dependencies of dependency management"

let prop_of : Xmelly.t -> prop = function
  | Element(key, _, [Text v]) -> (key, v)
  | Element(key, _, []) -> (key, "")
  | Element(x, _, _) -> failwith (x ^ ": invalid property format")
  | Text(x) -> failwith (x ^ ": loose text found inside properties")

let module_of : Xmelly.t -> string = function
  | Element("module", _, [Text m]) -> m
  | Element(x, _, _) -> failwith (x ^ ": invalid module format")
  | Text(x) -> failwith (x ^ ": loose text found inside modules")

let parent_of (l : Xmelly.t list) : parent =
  let find f = find_text f l |> get_or_fail (f ^ " is not set in parent") in
  let group = find "groupId" in
  let artifact = find "artifactId" in
  let version = find "version" in
  { group; artifact; version }

let project_of (l : Xmelly.t list) : t =
  let parent = find_element "parent" l |> Option.map parent_of in
  let group = find_text "groupId" l in
  let artifact = find_text "artifactId" l |> get_or_fail "artifactId not set" in
  let version = find_text "version" l in
  let id : id = { group; artifact; version } in
  let deps =
    find_element "dependencies" l |> Option.value ~default:[] |>
    List.map dep_of in
  let dep_mgmt =
    find_element "dependencyManagement" l |> Option.value ~default:[] |>
    find_element "dependencies" |> Option.value ~default:[] |>
    List.map dep_mgmt_of in
  let props = 
    find_element "properties" l |> Option.value ~default:[] |>
    List.map prop_of in
  let modules = 
    find_element "modules" l |> Option.value ~default:[] |>
    List.map module_of in
  { parent; id; deps; dep_mgmt; props; modules }

let from_smelly (xml : Xmelly.t) =
  match xml with
  | Element("project", _, l) -> project_of l
  | _ -> failwith "expecting 'project' as root node"

let parse_file pomfn =
  let pom = open_in pomfn in
  try
    let res = Xmelly.parse pom |> from_smelly in
    close_in pom;
    res
  with Failure x ->
    close_in_noerr pom;
    failwith (pomfn ^ ": " ^ x)
