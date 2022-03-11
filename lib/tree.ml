type t = { node : Efpom.dep; deps : t Seq.t }

let rec build_tree (node : Efpom.dep) : t =
  let deps = Efpom.from_dep node |> Efpom.deps_of |> Seq.map build_tree in
  { node; deps }

let rec fold_deps (deps : t Seq.t) =
  let dd = Seq.map (fun t -> t.node.id) deps |> Depmap.of_seq in
  let dr = Seq.map (fun t -> t.deps) deps |> Seq.map fold_deps in
  Seq.fold_left Depmap.merge_left dd dr

let resolve (pom : Efpom.t) =
  Efpom.deps_of pom |> Seq.map build_tree |> fold_deps |> Depmap.to_seq
