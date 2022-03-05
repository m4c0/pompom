module PropMap = Map.Make (String)

type prop_map = string PropMap.t

type t = {
  id : string * string * string;
  parent : t option Lazy.t;
  props : prop_map;
  deps : Dependency.map;
  dm : Dependency.map;
  bom : Dependency.map;
  parsed : Parser.t;
}

let id_of (tt : t) = tt.id
let ( |? ) opt fn = match opt with Some x -> Some x | None -> Lazy.force fn
let ( |! ) opt fn = match opt with Some x -> x | None -> Lazy.force fn
let ( |& ) opt fn = Option.map fn opt |> Option.join

let hasnt_dep (tt : t) (group, artifact, _) =
  Dependency.Map.find_opt { group; artifact } tt.deps |> Option.is_none

let rec dm_version (ga : Dependency.ga) (tt : t) : string option =
  Dependency.Map.find_opt ga tt.dm
  |& Dependency.version_of
  |? lazy (Lazy.force tt.parent |& dm_version ga)

let prop_regex = Str.regexp "\\${\\(.*\\)}"

let rec apply_props (tt : t) (s : string) : string =
  let rec pvalue k (tt : t) =
    PropMap.find_opt k tt.props |? Lazy.map (fun p -> p |& pvalue k) tt.parent
  in
  let p_or_fail s =
    let k = Str.matched_group 1 s in
    pvalue k tt |! lazy (Errors.fail k "missing property")
  in
  let ns = Str.global_substitute prop_regex p_or_fail s in
  if ns = s then s else apply_props tt ns

let rec rec_deps_seq (tt : t) =
  let fn (d : Dependency.t) =
    let fail =
      lazy
        (Errors.fail
           (d.ga.group ^ ":" ^ d.ga.artifact)
           "could not resolve version")
    in

    let v = d.version |? lazy (dm_version d.ga tt) |! fail in
    (d.ga.group, d.ga.artifact, v)
  in
  Dependency.seq_of_map tt.deps |> Seq.map fn |> Seq.append (parent_deps tt)

and parent_deps (tt : t) =
  Lazy.force tt.parent |> Option.to_seq |> Seq.flat_map rec_deps_seq
  |> Seq.filter (hasnt_dep tt)

let deps_seq (tt : t) =
  let props = apply_props tt in
  rec_deps_seq tt |> Seq.map (fun (g, a, v) -> (props g, props a, props v))

let modules_seq (tt : t) = tt.parsed.modules

let rec build_tree (scope : Scopes.t) (fname : string) : t =
  let fail fld = lazy (Errors.fail fld "missing field") in
  let p = Parser.parse_file fname in
  let g = p.id.group |? lazy (Parent_id.group_of p.parent) |! fail "groupId" in
  let a = p.id.artifact in
  let v =
    p.id.version |? lazy (Parent_id.version_of p.parent) |! fail "version"
  in
  let recurse (pg, pa, pv) =
    Repo.parent_of_pom fname pg pa pv |> build_tree scope
  in
  let deps = Seq.filter (Dependency.has_scope scope) p.deps |> Dependency.map_of_seq in
  let dm =
    p.dep_mgmt
    |> Seq.filter (Fun.negate Dependency.is_bom)
    |> Dependency.map_of_seq
  in
  let bom =
    p.dep_mgmt |> Seq.filter Dependency.is_bom |> Dependency.map_of_seq
  in
  let predefs =
    List.to_seq
      [
        ("project.groupId", g); ("project.artifactId", a); ("project.version", v);
      ]
  in
  let props = p.props |> Seq.append predefs |> PropMap.of_seq in
  let parent = lazy (Option.map recurse p.parent) in
  { id = (g, a, v); parent; deps; dm; bom; props; parsed = p }
