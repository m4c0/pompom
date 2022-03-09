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

module Map = Map.Make (struct
  type t = string * string * string option * string option

  let compare (ga, aa, ta, ca) (gb, ab, tb, cb) =
    let copt x y =
      match (x, y) with
      | None, None -> 0
      | Some xx, Some yy -> String.compare xx yy
      | None, Some _ -> -1
      | Some _, None -> 1
    in
    match String.compare ga gb with
    | 0 -> (
        match String.compare aa ab with
        | 0 -> ( match copt ta tb with 0 -> copt ca cb | x -> x)
        | x -> x)
    | x -> x
end)

let is_bom (tt : t) = tt.scope = Some "import" && tt.tp = Some "pom"
let has_scope (s : Scopes.t) (tt : t) = Scopes.matches s tt.scope

let unique_key (tt : t) =
  ((tt.ga.group, tt.ga.artifact, tt.tp, tt.classifier), tt)

let version_of (tt : t) =
  match tt.version with
  | None -> failwith (tt.ga.group ^ ":" ^ tt.ga.artifact ^ " - missing version")
  | Some v -> v

let id_of (tt : t) = (tt.ga.group, tt.ga.artifact, version_of tt)
let classifier_of (tt : t) = tt.classifier
let scope_of (tt : t) = tt.scope
let tp_of (tt : t) = tt.tp
let is_optional (tt : t) = Option.value ~default:false tt.optional

let exclusions_of (tt : t) =
  Seq.map (fun { group; artifact } -> (group, artifact)) tt.exclusions

let filename_of (ext : string) (tt : t) : string =
  Repo.asset_fname ext tt.ga.group tt.ga.artifact (Option.get tt.version)
