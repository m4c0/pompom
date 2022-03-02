type id = string * string * string
type t = { id : id; deps : string Ga_map.t; modules : string list }
type scope = Scopes.t

let deps_seq (tt : t) : id Seq.t =
  Ga_map.to_seq tt.deps |> Seq.map (fun ((g, a), v) -> (g, a, v))

let modules_seq (tt : t) : string Seq.t = List.to_seq tt.modules

let asset_fname (ext : string) ((g, a, v) : id) : string =
  Repo.asset_fname ext g a v

let rec from_pom (scope : scope) (fname : string) : t =
  let id, dmap, modules = Deps.resolve scope fname in
  let recurse (ga, v) =
    match Ga_map.find_opt ga dmap with
    | Some vv -> Seq.return (ga, vv)
    | None ->
        let g, a = ga in
        let ({ deps; _ } : t) =
          asset_fname "pom" (g, a, v) |> from_pom Compile
        in
        Ga_map.to_seq deps |> Seq.cons (ga, v)
  in
  let flat_id ((g, a), v) = (g, a, v) in
  let pom_deps id =
    flat_id id |> asset_fname "pom"
    |> Deps.resolve (Scopes.transitive_of scope)
    |> (fun (_, d, _) -> d)
    |> Ga_map.to_seq |> Seq.map recurse |> Seq.concat |> Seq.cons id
  in
  let deps =
    Ga_map.to_seq dmap |> Seq.map pom_deps |> Seq.concat |> Ga_map.of_seq
  in
  { id; deps; modules }

let from_java (scope : scope) fname =
  let rec pom_of fname =
    let pom = Filename.concat fname "pom.xml" in
    if Sys.file_exists pom then pom else fname |> Filename.dirname |> pom_of
  in
  pom_of fname |> from_pom scope
