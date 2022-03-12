type ga = { group : string; artifact : string }

type t = {
  ga : ga;
  version : string option;
  classifier : string option;
  scope : string;
  tp : string;
  exclusions : ga Seq.t;
  optional : bool option;
}

let is_bom (tt : t) = tt.scope = "import" && tt.tp = "pom"
let has_scope (s : Scopes.t) (tt : t) = Scopes.matches s tt.scope
let unique_key (tt : t) = (tt.ga.group, tt.ga.artifact, tt.tp, tt.classifier)

let id_of vopt (tt : t) =
  let v : string =
    match tt.version with
    | None -> (
        match vopt with
        | None ->
            tt.ga.group ^ ":" ^ tt.ga.artifact ^ " - missing version"
            |> failwith
        | Some d -> d)
    | Some v -> v
  in
  (tt.ga.group, tt.ga.artifact, v)

let classifier_of (tt : t) = tt.classifier
let scope_of (tt : t) = tt.scope
let tp_of (tt : t) = tt.tp
let is_optional (tt : t) = Option.value ~default:false tt.optional

let exclusions_of (tt : t) =
  Seq.map (fun { group; artifact } -> (group, artifact)) tt.exclusions

let filename_of (ext : string) (tt : t) : string =
  Repo.asset_fname ext tt.ga.group tt.ga.artifact (Option.get tt.version)
