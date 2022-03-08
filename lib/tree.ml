type 'a ctx = {
  scope : Scopes.t;
  cache : 'a Seq.t Tree_cache.t;
  props : Properties.t;
  dep_mgmt : Depmgmt.t Seq.t;
}

type t = {
  fpom : Efpom.t;
  deps : Dependency.t Seq.t;
  resolver : bool -> t ctx -> string -> t Seq.t;
  modules : string Seq.t;
  ctx : t ctx;
}

let seq_or_die fld msg (seq : 'a Seq.t) =
  match seq () with Nil -> Errors.fail fld msg | Cons (v, _) -> v

let id_of (tt : t) = Efpom.id_of tt.fpom
let modules_seq (tt : t) = tt.modules

let is_excl excl (d : Dependency.ga) =
  let excl = Seq.filter (fun x -> x = d) excl in
  match excl () with Nil -> false | _ -> true

let%test "is_excl" =
  let ga : Dependency.ga = { group = "aa"; artifact = "bb" } in
  let seq = Seq.return ga in
  is_excl seq ga && is_excl Seq.empty ga |> not

let rec resolve exists excl (tt : t) : Efpom.id Seq.t =
  let apply_props (g, a, v, d) =
    let apply = Properties.apply tt.ctx.props in
    (apply g, apply a, (apply v, d))
  in
  let dm d fn =
    Seq.flat_map (Depmgmt.find d) tt.ctx.dep_mgmt |> Seq.flat_map fn
  in
  let opt d =
    match dm d Depmgmt.optional_of () with Nil -> false | Cons (v, _) -> v
  in
  let exclusions d = dm d Depmgmt.exclusions_of in
  let find_version (d : Dependency.t) =
    let g = d.ga.group in
    let a = d.ga.artifact in
    let v =
      dm d Depmgmt.version_of |> seq_or_die (g ^ ":" ^ a) "missing version"
    in
    (g, a, v, d)
  in

  let ex_ex (d : Dependency.t) = exists d || is_excl excl d.ga in

  let deps =
    Seq.filter (Fun.negate ex_ex) tt.deps
    |> Seq.map find_version |> Seq.map apply_props |> Depmap.of_seq
  in
  let exists (d : Dependency.t) = ex_ex d || Depmap.exists d deps in

  let dep_map (g, a, (v, d)) =
    let transitive_scope = Scopes.transitive_of tt.ctx.scope in
    let new_ctx = { tt.ctx with scope = transitive_scope } in
    Repo.asset_fname "pom" g a v
    |> tt.resolver (opt d) new_ctx
    |> Seq.map (fun t -> (d, t))
  in
  let dep_seq = Depmap.to_seq deps |> Seq.flat_map dep_map in

  let next_map (d, t) = resolve exists (exclusions d) t in
  let next_seq = Seq.flat_map next_map dep_seq in
  let this_seq = Seq.map (fun (_, t) -> Efpom.id_of t.fpom) dep_seq in
  Seq.append this_seq next_seq

let deps_seq (tt : t) = resolve (fun _ -> false) Seq.empty tt

let rec really_build_tree (ctx : t ctx) (fname : string) : t =
  let really_try_build_tree is_opt c f : t Seq.t =
    if is_opt then try really_build_tree c f |> Seq.return with _ -> Seq.empty
    else
      try really_build_tree c f |> Seq.return with
      | Failure x -> x ^ "\nwhile parsing " ^ fname |> failwith
      | Sys_error x -> x ^ "\nwhile parsing " ^ fname |> failwith
  in
  let try_build_tree is_opt c f : t Seq.t =
    Tree_cache.retrieve f (really_try_build_tree is_opt c) c.cache
  in
  let p = Parser.parse_file fname in
  let fpom = Efpom.from_pom fname in
  let scope = ctx.scope in

  let parent =
    p.parent |> Option.to_seq
    |> Seq.map (fun (g, a, v) -> Repo.asset_fname "pom" g a v)
    |> Seq.flat_map (try_build_tree false ctx)
  in
  let modules = p.modules in

  let my_deps = Seq.filter (Dependency.has_scope scope) p.deps in
  let parent_deps = Seq.flat_map (fun p -> p.deps) parent in
  let deps = List.to_seq [ my_deps; parent_deps ] |> Seq.concat in

  let base_dm = ctx.dep_mgmt in
  let deps_dm = Depmgmt.of_dep_seq deps |> Seq.return in
  let my_dm =
    Seq.filter (Fun.negate Dependency.is_bom) p.dep_mgmt
    |> Depmgmt.of_dep_seq |> Seq.return
  in
  let parent_dm = parent |> Seq.flat_map (fun p -> p.ctx.dep_mgmt) in
  let dm_so_far =
    [ base_dm; deps_dm; my_dm; parent_dm ] |> List.to_seq |> Seq.concat
  in

  let bom_mapper (d : Dependency.t) =
    (* TODO: does this inherit? *)
    let opt = Option.value ~default:false d.optional in

    Dependency.filename_of "pom" d
    |> Properties.apply ctx.props |> try_build_tree opt ctx
    |> Seq.flat_map (fun tt -> tt.ctx.dep_mgmt)
  in
  let bom_dm =
    Seq.filter Dependency.is_bom p.dep_mgmt |> Seq.flat_map bom_mapper
  in
  let dep_mgmt = Seq.append dm_so_far bom_dm in
  let ctx = { ctx with dep_mgmt } in

  let resolver = try_build_tree in

  { fpom; deps; modules; resolver; ctx }

let build_tree (scope : Scopes.t) (fname : string) : t =
  let cache = Tree_cache.empty () in
  let ctx = { scope; cache; dep_mgmt = Seq.empty; props = Seq.empty |> Properties.of_seq } in
  really_build_tree ctx fname
