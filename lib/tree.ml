type t = { node : Efpom.dep; deps : t Seq.t }

module Map = Map.Make (struct
  type t = string * string

  let compare (ga, aa) (gb, ab) =
    match String.compare ga gb with 0 -> String.compare aa ab | x -> x
end)

let rec build_tree (depmap : 'a Depmap.t) (node : Efpom.dep) : t * 'a Depmap.t =
  let key_of (dep : Efpom.dep) =
    let g, a, _ = dep.id in
    (g, a, dep.tp, dep.classifier)
  in
  let find_dep (d : 'a Depmap.t) (dep : Efpom.dep) =
    let k = key_of dep in
    Depmap.find_opt k d
  in
  let only_new (dep : Efpom.dep) = find_dep depmap dep |> Option.is_none in
  let fold acc dep =
    let nt, nm = build_tree acc dep in
    Depmap.add (key_of dep) nt nm
  in
  let filtered = Efpom.from_dep node |> Efpom.deps_of |> Seq.filter only_new in
  let map = Seq.fold_left fold depmap filtered in
  let deps = Seq.map (find_dep map) filtered |> Seq.map Option.get in
  ({ node; deps }, map)

let build_tree_of_pom (pom : Efpom.t) =
  Efpom.deps_of pom |> Seq.map (build_tree Depmap.empty)

let resolve (pom : Efpom.t) =
  build_tree_of_pom pom
  |> Seq.map (fun (_, map) -> map)
  |> Seq.fold_left (fun _ map -> map) Depmap.empty
  |> Depmap.to_seq
  |> Seq.map (fun (_, (tt : t)) -> tt.node.id)
