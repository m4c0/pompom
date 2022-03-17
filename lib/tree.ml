type efdep = Efdep.t
type efdep_map = efdep Depmap.t
type t = { node : efdep; deps : t Queue.t }

type ctx = {
  dm : efdep_map;
  depmap : efdep_map;
  excl : Exclusions.t;
  scope : Scopes.t;
}

let deps_of (tt : t) = Queue.to_seq tt.deps
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

let depy ctx (node : efdep) =
  Efpom.from_dep node |> apply_dms ctx.dm
  |> Seq.filter_map (Efdep.rescope node)
  |> Seq.filter (Efdep.has_scope ctx.scope)
  |> Seq.filter (Exclusions.accepts ctx.excl)
  |> Seq.filter (Fun.negate Efdep.is_optional)

let rec just_do_it ctx pending =
  match Queue.take_opt pending with
  | None -> ctx.depmap
  | Some (_, x) when Depmap.exists (Efdep.unique_key_of x) ctx.depmap ->
      just_do_it ctx pending
  | Some (pq, dep) ->
      let depmap = Depmap.add (Efdep.unique_key_of dep) dep ctx.depmap in
      let excl = Exclusions.add_seq (Efdep.exclusions_of dep) ctx.excl in
      let ctx = { ctx with depmap; excl } in
      let q = Queue.create () in
      let tt = { node = dep; deps = q } in
      let deps = depy ctx dep |> Seq.map (fun d -> (q, d)) in
      Queue.add tt pq;
      Queue.add_seq pending deps;
      just_do_it ctx pending

let start scope pom q =
  let dm = Efpom.depmgmt_of pom |> map_of_seq in
  let excl = Exclusions.Set.empty in
  let depmap = Depmap.empty in
  let ctx = { dm; scope; excl; depmap } in
  let pending =
    Efpom.deps_of pom
    |> Seq.filter (Efdep.has_scope scope)
    |> Seq.map (fun d -> (q, d))
    |> Queue.of_seq
  in
  just_do_it ctx pending

let iter scope pom =
  let root = Queue.create () in
  start scope pom root |> ignore;
  Queue.to_seq root

let resolve scope pom =
  let root = Queue.create () in
  start scope pom root |> Depmap.to_seq |> Seq.map (fun (_, v) -> Efdep.id_of v)
