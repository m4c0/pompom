type id = { group : string option; artifact : string; version : string option }
type prop = string * string
type parent = string * string * string

type t = {
  parent : parent option;
  id : id;
  deps : Dependency.t Seq.t;
  dep_mgmt : Dependency.t Seq.t;
  props : prop Seq.t;
  modules : string Seq.t;
}

let findopt_element (t : string) (l : Xmelly.t list) : Xmelly.t list option =
  let fn : Xmelly.t -> Xmelly.t list option = function
    | Element (x, _, xs) when x = t -> Some xs
    | _ -> None
  in
  List.find_map fn l

let find_element (t : string) (l : Xmelly.t list) : Xmelly.t list =
  findopt_element t l |> Option.value ~default:[]

let findmap_all_elements (fn : Xmelly.t -> 'a) (t : string) (l : Xmelly.t list)
    : 'a Seq.t =
  find_element t l |> List.to_seq |> Seq.map fn

let find_text (t : string) (l : Xmelly.t list) : string option =
  let fn : Xmelly.t -> string option = function
    | Element (x, _, [ Text tt ]) when x = t -> Some tt
    | _ -> None
  in
  List.find_map fn l

let get_or_fail msg = function Some x -> x | None -> failwith msg

let ga_of (fld : string) (l : Xmelly.t list) : Dependency.ga =
  let find f = find_text f l |> get_or_fail (f ^ " is not set in " ^ fld) in
  let group = find "groupId" in
  let artifact = find "artifactId" in
  { group; artifact }

let excl_of : Xmelly.t -> Dependency.ga = function
  | Element ("exclusion", _, l) -> ga_of "exclusion" l
  | _ -> failwith "found weird stuff inside exclusions"

let dep_of : Xmelly.t -> Dependency.t = function
  | Element ("dependency", _, l) ->
      let ga = ga_of "dependency" l in
      let version = find_text "version" l in
      let scope = find_text "scope" l |> Option.value ~default:"compile" in
      let tp = find_text "type" l |> Option.value ~default:"jar" in
      let exclusions = findmap_all_elements excl_of "exclusions" l in
      let classifier = find_text "classifier" l in
      let optional =
        find_text "optional" l |> Option.map (String.equal "true")
      in
      { ga; version; scope; classifier; exclusions; tp; optional }
  | _ -> failwith "found weird stuff inside dependencies"

let prop_of : Xmelly.t -> prop = function
  | Element (key, _, [ Text v ]) -> (key, v)
  | Element (key, _, []) -> (key, "")
  | Element (x, _, _) -> failwith (x ^ ": invalid property format")
  | Text x -> failwith (x ^ ": loose text found inside properties")

let module_of : Xmelly.t -> string = function
  | Element ("module", _, [ Text m ]) -> m
  | Element (x, _, _) -> failwith (x ^ ": invalid module format")
  | Text x -> failwith (x ^ ": loose text found inside modules")

let parent_of (l : Xmelly.t list) : parent =
  let find f = find_text f l |> get_or_fail (f ^ " is not set in parent") in
  let group = find "groupId" in
  let artifact = find "artifactId" in
  let version = find "version" in
  (group, artifact, version)

let project_of (l : Xmelly.t list) : t =
  let parent = findopt_element "parent" l |> Option.map parent_of in
  let group = find_text "groupId" l in
  let artifact = find_text "artifactId" l |> get_or_fail "artifactId not set" in
  let version = find_text "version" l in
  let id : id = { group; artifact; version } in
  let deps = findmap_all_elements dep_of "dependencies" l in
  let dep_mgmt =
    find_element "dependencyManagement" l
    |> findmap_all_elements dep_of "dependencies"
  in
  let props = findmap_all_elements prop_of "properties" l in
  let modules = findmap_all_elements module_of "modules" l in
  { parent; id; deps; dep_mgmt; props; modules }

let from_smelly (xml : Xmelly.t) =
  match xml with
  | Element ("project", _, l) -> project_of l
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
