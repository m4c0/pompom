type ga = { group : string; artifact : string }

type t = {
  ga : ga;
  version : string option;
  scope : string option;
  tp : string option;
  exclusions : ga Seq.t;
}

let id_of (tt : t) = (tt.ga.group, tt.ga.artifact, tt.version)
let version_of (tt : t) = tt.version
let is_bom (tt : t) = tt.scope = Some "import" && tt.tp = Some "pom"
let has_scope (s : Scopes.t) (tt : t) = Scopes.matches s tt.scope

let filename_of (ext : string) (tt : t) : string =
  Repo.asset_fname ext tt.ga.group tt.ga.artifact (Option.get tt.version)

module Map = Map.Make (struct
  type t = ga

  let compare (a : t) (b : t) =
    match String.compare a.group b.group with
    | 0 -> String.compare a.artifact b.artifact
    | x -> x
end)

type map = t Map.t

let map_of_seq (seq : t Seq.t) =
  Seq.map (fun (tt : t) -> (tt.ga, tt)) seq |> Map.of_seq

let seq_of_map (m : map) = Map.to_seq m |> Seq.map (fun (_, v) -> v)

let unique_seq (seq : t Seq.t) =
  let fn m (tt : t) =
    match Map.find_opt tt.ga m with Some _ -> m | None -> Map.add tt.ga tt m
  in
  Seq.fold_left fn Map.empty seq |> seq_of_map
