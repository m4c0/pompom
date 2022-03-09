type t = {
  id : string * string * string;
  deps : (string * string * string) Seq.t;
  modules : string Seq.t;
}

let id_of t = t.id
let deps_of t = t.deps
let modules_of t = t.modules

let rec resolve_deps (t : Efpom.t) =
  let take_id = Seq.map (fun (d : Efpom.dep) -> d.id) in
  let d = Efpom.deps_of t |> take_id in
  Seq.map (fun (g, a, v) -> Repo.asset_fname "pom" g a v) d
  |> Seq.map Efpom.from_pom |> Seq.flat_map resolve_deps
  |> Seq.append d |> Depmap.of_seq
  |> Depmap.merge_left (Depmap.of_seq d)
  |> Depmap.to_seq

let build_tree (_ : Scopes.t) (fname : string) : t =
  let root = Efpom.from_pom fname in
  let deps = resolve_deps root in
  { id = Efpom.id_of root; deps; modules = Efpom.modules_of root }
