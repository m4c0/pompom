type efdep = Efdep.t
type efdep_map = efdep Depmap.t
type t = { node : efdep; deps : t Seq.t }

type ctx = {
  dm : efdep_map;
  depmap : efdep_map;
  excl : Exclusions.t;
  scope : Scopes.t;
}

let deps_of (tt : t) = tt.deps
let node_of (tt : t) = tt.node

let map_of_seq seq =
  Seq.map (fun d -> (Efdep.unique_key_of d, d)) seq |> Depmap.of_seq

let apply_dms dms deps =
  let apply_dm dep =
    let key = Efdep.unique_key_of dep in
    let dm = Depmap.find_opt key dms in
    Efdep.extend_with ~default:dm dep
  in
  Efpom.deps_of deps |> Seq.map apply_dm

let rec build_tree ctx (node : efdep) : t * efdep_map =
  let nkey = Efdep.unique_key_of node in
  let fold (accm, accl) dep =
    let key = Efdep.unique_key_of dep in
    if key = nkey then (accm, accl)
    else if Depmap.find_opt key accm |> Option.is_some then (accm, accl)
    else
      let excl = Exclusions.add_seq (Efdep.exclusions_of dep) ctx.excl in
      let nt, nm =
        try build_tree { ctx with excl; depmap = accm } dep
        with Sys_error e ->
          let fname = Efdep.to_mvn_str node in
          let msg = Printf.sprintf "%s\nwhile traversing %s" e fname in
          Sys_error msg |> raise
      in
      let m = Depmap.add key dep nm in
      (m, nt :: accl)
  in
  let map, rdeps =
    Efpom.from_dep node |> apply_dms ctx.dm
    |> Seq.filter_map (Efdep.rescope node)
    |> Seq.filter (Efdep.has_scope ctx.scope)
    |> Seq.filter (Exclusions.accepts ctx.excl)
    |> Seq.filter (Fun.negate Efdep.is_optional)
    |> Seq.fold_left fold (ctx.depmap, [])
  in
  let deps = List.rev rdeps |> List.to_seq in
  ({ node; deps }, map)

let fold_deps_of fn scope (pom : Efpom.t) =
  let dm = Efpom.depmgmt_of pom |> map_of_seq in
  let fold acc dep =
    let excl = Efdep.exclusions_of dep |> Exclusions.of_seq in
    let ctx = { dm; depmap = acc; excl; scope } in
    let node, map = build_tree ctx dep in
    fn node;
    map
  in
  let depmap =
    Efpom.deps_of pom |> Seq.filter (Efdep.has_scope scope) |> map_of_seq
  in
  Depmap.to_seq depmap |> Seq.map (fun (_, d) -> d) |> Seq.fold_left fold depmap

let iter scope fn pom = fold_deps_of fn scope pom |> ignore

let resolve scope (pom : Efpom.t) =
  fold_deps_of (fun _ -> ()) scope pom
  |> Depmap.to_seq
  |> Seq.map (fun (_, d) -> Efdep.id_of d)
