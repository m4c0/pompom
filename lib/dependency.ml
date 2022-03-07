type ga = { group : string; artifact : string }

type t = {
  ga : ga;
  version : string option;
  scope : string option;
  tp : string option;
  exclusions : ga Seq.t;
  optional : bool option;
}

let is_bom (tt : t) = tt.scope = Some "import" && tt.tp = Some "pom"
let has_scope (s : Scopes.t) (tt : t) = Scopes.matches s tt.scope

let filename_of (ext : string) (tt : t) : string =
  Repo.asset_fname ext tt.ga.group tt.ga.artifact (Option.get tt.version)

