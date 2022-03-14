type efdep = Efdep.t
type efdep_map = efdep Depmap.t
type t = { node : efdep; deps : t Seq.t }

let deps_of (tt : t) = tt.deps
let node_of (tt : t) = tt.node

let map_of_seq seq =
  Seq.map (fun d -> (Efdep.unique_key_of d, d)) seq |> Depmap.of_seq

let rec build_tree (dm : efdep_map) (depmap : efdep_map) (node : efdep) :
    t * efdep_map =
  let fold (accm, accl) dep =
    let key = Efdep.unique_key_of dep in
    if Depmap.find_opt key accm |> Option.is_some then (accm, accl)
    else
      let dep = dep in
      let nt, nm = build_tree dm accm dep in
      let m = Depmap.add key dep nm in
      (m, nt :: accl)
  in
  let map, rdeps =
    Efpom.from_dep node |> Efpom.deps_of |> Seq.fold_left fold (depmap, [])
  in
  let deps = List.rev rdeps |> List.to_seq in
  ({ node; deps }, map)

let fold_deps_of fn (pom : Efpom.t) =
  let dm = Efpom.depmgmt_of pom |> map_of_seq in
  let fold acc dep =
    let node, map = build_tree dm acc dep in
    fn node;
    map
  in
  let depmap = Efpom.deps_of pom |> map_of_seq in
  Efpom.deps_of pom |> Seq.fold_left fold depmap

let iter fn pom = fold_deps_of fn pom |> ignore

let resolve (pom : Efpom.t) =
  fold_deps_of (fun _ -> ()) pom
  |> Depmap.to_seq
  |> Seq.map (fun (_, d) -> Efdep.id_of d)
