type t = { pom : Efpom.t; deps : t Seq.t }
type ctx = { scope : Scopes.t }

let rec build_tree (ctx : ctx) (pom : Efpom.t) : t =
  let is_scoped (d : Efpom.dep) = Scopes.matches ctx.scope d.scope in
  let deps =
    Efpom.deps_of pom |> Seq.filter is_scoped |> Seq.map Efpom.from_dep
    |> Seq.map (build_tree ctx)
  in
  { pom; deps }

let rec fold_deps (tt : t) =
  let dd =
    Seq.map (fun t -> t.pom) tt.deps |> Seq.map Efpom.id_of |> Depmap.of_seq
  in
  let dr = Seq.map fold_deps tt.deps in
  Seq.fold_left Depmap.merge_left dd dr

let resolve (scope : Scopes.t) (pom : Efpom.t) =
  let ctx = { scope } in
  build_tree ctx pom |> fold_deps |> Depmap.to_seq
