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
  let fold (accm, accl) dep =
    let key = key_of dep in
    if Depmap.find_opt key accm |> Option.is_some then (accm, accl)
    else
      let nt, nm = build_tree accm dep in
      let m = Depmap.add key nt nm in
      (m, nt :: accl)
  in
  let map, rdeps =
    Efpom.from_dep node |> Efpom.deps_of |> Seq.fold_left fold (depmap, [])
  in
  let deps = List.rev rdeps |> List.to_seq in
  ({ node; deps }, map)

let fold_deps_of fold (pom : Efpom.t) =
  Efpom.deps_of pom
  |> Seq.fold_left fold Depmap.empty

let resolve (pom : Efpom.t) =
  let fold acc dep =
    let _, map = build_tree acc dep in
    map
  in
  fold_deps_of fold pom
  |> Depmap.to_seq
  |> Seq.map (fun (_, (tt : t)) -> tt.node.id)
