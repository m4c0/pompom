type ga = { group : string; artifact : string }

type t = {
  ga : ga;
  version : string option;
  scope : string option;
  tp : string option;
  exclusions : ga Seq.t;
  optional : bool option;
}

let id_of (tt : t) = (tt.ga.group, tt.ga.artifact, tt.version)
let version_of (tt : t) = tt.version
let is_bom (tt : t) = tt.scope = Some "import" && tt.tp = Some "pom"
let has_scope (s : Scopes.t) (tt : t) = Scopes.matches s tt.scope

let filename_of (ext : string) (tt : t) : string =
  Repo.asset_fname ext tt.ga.group tt.ga.artifact (Option.get tt.version)

let map_id (tt : t) =
  Option.map (fun v -> (tt.ga.group, tt.ga.artifact, v)) tt.version
