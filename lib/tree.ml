type efdep = Efpom.dep
type efdep_map = efdep Depmap.t
type t = { node : efdep; deps : t Seq.t }

let deps_of (tt : t) = tt.deps
let node_of (tt : t) = tt.node

let key_of (dep : efdep) =
  let g, a, _ = dep.id in
  (g, a, dep.tp, dep.classifier)

let rec build_tree (depmap : efdep_map) (node : efdep) : t * efdep_map =
  let fold (accm, accl) dep =
    let key = key_of dep in
    if Depmap.find_opt key accm |> Option.is_some then (accm, accl)
    else
      let dep = dep in
      let nt, nm = build_tree accm dep in
      let m = Depmap.add key dep nm in
      (m, nt :: accl)
  in
  let map, rdeps =
    Efpom.from_dep node |> Efpom.deps_of |> Seq.fold_left fold (depmap, [])
  in
  let deps = List.rev rdeps |> List.to_seq in
  ({ node; deps }, map)

let fold_deps_of fold (pom : Efpom.t) =
  let depmap =
    Efpom.deps_of pom |> Seq.map (fun d -> (key_of d, d)) |> Depmap.of_seq
  in
  Efpom.deps_of pom |> Seq.fold_left fold depmap

let iter fn pom =
  let fold acc dep =
    let node, map = build_tree acc dep in
    fn node;
    map
  in
  fold_deps_of fold pom |> ignore

let resolve (pom : Efpom.t) =
  let fold acc dep =
    let _, map = build_tree acc dep in
    map
  in
  fold_deps_of fold pom |> Depmap.to_seq
  |> Seq.map (fun (_, (d : efdep)) -> d.id)
