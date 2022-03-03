(**
   Read and merge the POM hiearchy into a single POM.
   Given a parseable file, it dives into its <parent> hiearchy to merge its
   properties into a single structure
*)
let rec parse_and_merge (pom : string) : Parser.t =
  let parse_parent (g, a, v) : Parser.t =
    Repo.parent_of_pom pom g a v |> parse_and_merge
  in
  let parsed = Parser.parse_file pom in

  let get_or_inherit fld v fn =
    match v with
    | Some value -> Some value
    | None -> (
        match Option.map fn parsed.parent with
        | Some p -> Some p
        | None -> "missing " ^ fld |> failwith)
  in
  let group = get_or_inherit "group" parsed.id.group (fun (g, _, _) -> g) in
  let version =
    get_or_inherit "version" parsed.id.version (fun (_, _, v) -> v)
  in
  let id = { parsed.id with group; version } in

  let parent = Option.map parse_parent parsed.parent in

  let inherit_seq pfn =
    let v = pfn parsed in
    Option.map pfn parent |> Option.value ~default:Seq.empty |> Seq.append v
  in
  let deps = inherit_seq (fun (p : Parser.t) -> p.deps) in
  let dep_mgmt = inherit_seq (fun (p : Parser.t) -> p.dep_mgmt) in
  let props = inherit_seq (fun (p : Parser.t) -> p.props) in

  { parsed with id; deps; dep_mgmt; props }
