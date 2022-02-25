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

let asset_fname (ext : string) ((g, a, v) : id) : string =
  Repo.asset_fname ext g a v

let from_java fname =
  let rec pom_of fname = 
    let pom = Filename.concat fname "pom.xml" in
    if Sys.file_exists pom
    then pom
    else fname |> Filename.dirname |> pom_of
  in
  let res = pom_of fname |> from_pom in
  let rec rd (tt : t) : id Seq.t =
    deps_seq tt
    |> Seq.map (asset_fname "pom")
    |> Seq.map from_pom
    |> Seq.map rd
    |> Seq.concat
    |> Seq.append (deps_seq tt)
  in
  let deps = 
    rd res
    |> Seq.map (fun (g, a, v) -> ((g, a), v))
    |> Ga_map.of_seq
  in
  { res with deps }
