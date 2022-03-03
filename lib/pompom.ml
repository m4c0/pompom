type id = string * string * string
type t = Aggregator.t
type scope = Scopes.t

let id_of (tt : t) : id = tt.id

let deps_seq (tt : t) : id Seq.t =
  Ga_map.to_seq tt.deps
  |> Seq.map (fun ((ga : Pom.ga), v) -> (ga.group, ga.artifact, v))

let modules_seq (tt : t) : string Seq.t = List.to_seq tt.modules

let asset_fname (ext : string) ((g, a, v) : id) : string =
  Repo.asset_fname ext g a v

let from_pom (scope : scope) (fname : string) : t = Deps.resolve scope fname

let from_java (scope : scope) fname =
  let rec pom_of fname =
    let pom = Filename.concat fname "pom.xml" in
    if Sys.file_exists pom then pom else fname |> Filename.dirname |> pom_of
  in
  pom_of fname |> from_pom scope
