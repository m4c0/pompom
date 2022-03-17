type t = {
  id : string * string * string;
  exclusions : (string * string) Seq.t;
  classifier : string option;
  optional : bool;
  scope : string option;
  tp : string;
  is_bom : bool;
}

let classifier_of tt = tt.classifier
let exclusions_of tt = tt.exclusions
let filename_of { id = g, a, v; _ } = Repo.asset_fname "pom" g a v
let id_of tt = tt.id
let is_bom tt = tt.is_bom
let is_optional tt = tt.optional
let scope_of tt = Option.value ~default:"compile" tt.scope
let unique_key_of { id = g, a, _; tp; classifier; _ } = (g, a, tp, classifier)
let version_of { id = _, _, v; _ } = v
let has_scope s tt = Scopes.matches s (scope_of tt)

let apply_props props ({ id = g, a, v; _ } as tt : t) =
  let apply = Properties.apply props in
  let id = (apply g, apply a, apply v) in
  let classifier =
    match Option.map (Properties.apply props) tt.classifier with
    | Some "" -> None
    | x -> x
  in
  { tt with id; classifier }

let of_parsed dm d =
  let dmopt = Depmap.find_opt (Dependency.unique_key d) dm in
  let dm_v = Option.map version_of dmopt in
  let dm_exc = Option.map exclusions_of dmopt |> Option.to_seq |> Seq.concat in
  let dm_s = Option.map scope_of dmopt in
  {
    classifier = Dependency.classifier_of d;
    id = Dependency.id_of dm_v d;
    exclusions = Dependency.exclusions_of d |> Seq.append dm_exc;
    optional = Dependency.is_optional d;
    scope = Option.fold ~none:dm_s ~some:Option.some (Dependency.scope_of d);
    tp = Dependency.tp_of d;
    is_bom = Dependency.is_bom d;
  }

let extend_with ~default tt =
  match default with
  | None -> tt
  | Some { id; scope; exclusions; _ } ->
      let exclusions = Seq.append tt.exclusions exclusions in
      let scope =
        [ tt.scope; scope; Some "compile" ]
        |> List.filter_map Fun.id |> List.hd |> Option.some
      in
      { tt with id; scope; exclusions }

let rescope stt tt =
  Scopes.transitive_of stt.scope tt.scope 
  |> Option.map (fun s -> { tt with scope = Some s })

let to_mvn_str ({ id = g, a, v; tp; _ } as tt) =
  [ g; a; tp; v; scope_of tt ] |> String.concat ":"
