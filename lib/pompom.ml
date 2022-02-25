type id = string * string * string
type t = {
  id : id;
  deps : string Ga_map.t;
  modules : string list;
}

let deps_seq (tt : t) : id Seq.t =
  Ga_map.to_seq tt.deps
  |> Seq.map (fun ((g, a), v) -> (g, a, v))

let modules_seq (tt : t) : string Seq.t =
  List.to_seq tt.modules

let from_pom fname =
  let (id, deps, modules) = Deps.resolve fname in
  { id; deps; modules }

let from_java fname =
  let rec pom_of fname = 
    let pom = Filename.concat fname "pom.xml" in
    if Sys.file_exists pom
    then pom
    else fname |> Filename.dirname |> pom_of
  in
  pom_of fname |> from_pom

let transitive_resolve_deps (tt : t) : id Seq.t =
  let fn (g, a, v) = (g, a, v) in
  deps_seq tt |> Seq.map fn
