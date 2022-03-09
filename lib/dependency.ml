type ga = { group : string; artifact : string }

type t = {
  ga : ga;
  version : string option;
  classifier : string option;
  scope : string option;
  tp : string option;
  exclusions : ga Seq.t;
  optional : bool option;
}

let is_bom (tt : t) = tt.scope = Some "import" && tt.tp = Some "pom"
let has_scope (s : Scopes.t) (tt : t) = Scopes.matches s tt.scope
let ga_pair_of (tt : t) = ((tt.ga.group, tt.ga.artifact), tt)

let version_of (tt : t) =
  match tt.version with
  | None -> failwith (tt.ga.group ^ ":" ^ tt.ga.artifact ^ " - missing version")
  | Some v -> v
let id_of (tt : t) = (tt.ga.group, tt.ga.artifact, version_of tt)
let classifier_of (tt : t) = tt.classifier
let tp_of (tt : t) = tt.tp
let is_optional (tt : t) = Option.value ~default:false tt.optional
let exclusions_of (tt : t) = Seq.map (fun { group; artifact } -> (group, artifact)) tt.exclusions

let filename_of (ext : string) (tt : t) : string =
  Repo.asset_fname ext tt.ga.group tt.ga.artifact (Option.get tt.version)
