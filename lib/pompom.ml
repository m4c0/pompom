type id = string * string * string
type t = {
  id : id;
  deps : string Ga_map.t;
  modules : string list;
}
type scope = Compile | Test | Runtime

let deps_seq (tt : t) : id Seq.t =
  Ga_map.to_seq tt.deps
  |> Seq.map (fun ((g, a), v) -> (g, a, v))

let modules_seq (tt : t) : string Seq.t =
  List.to_seq tt.modules

let asset_fname (ext : string) ((g, a, v) : id) : string =
  Repo.asset_fname ext g a v

let rec from_pom (scope : scope) (fname : string) : t =
  let scope_list =
    match scope with
    | Compile -> ["compile"]
    | Runtime -> ["compile";"provided"]
    | Test -> ["compile";"test";"provided"]
  in
  let (id, dmap, modules) = Deps.resolve scope_list fname in
  let rec rd (dd : id Seq.t) : id Seq.t =
    dd
    |> Seq.map (asset_fname "pom")
    |> Seq.map (from_pom Compile)
    |> Seq.map deps_seq
    |> Seq.map rd
    |> Seq.concat
    |> Seq.append dd
  in
  let deps = 
    Ga_map.to_seq dmap
    |> Seq.map (fun ((g, a), v) -> (g, a, v))
    |> rd
    |> Seq.map (fun (g, a, v) -> ((g, a), v))
    |> Ga_map.of_seq
  in
  { id; deps; modules }

let from_java (scope : scope) fname =
  let rec pom_of fname = 
    let pom = Filename.concat fname "pom.xml" in
    if Sys.file_exists pom
    then pom
    else fname |> Filename.dirname |> pom_of
  in
  pom_of fname |> from_pom scope
