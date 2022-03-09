type id = string * string * string
type t = { id : id; deps : id Seq.t; modules : string Seq.t }
type scope = Scopes.t

module Impl_EffectivePom = Efpom
module Impl_Tree = Tree

let id_of (tt : t) : id = tt.id
let deps_seq (tt : t) : id Seq.t = tt.deps
let modules_seq (tt : t) : string Seq.t = tt.modules

let asset_fname (ext : string) ((g, a, v) : id) : string =
  Repo.asset_fname ext g a v

let from_pom (s : scope) (fname : string) : t =
  let tree = Tree.build_tree s fname in
  {
    id = Tree.id_of tree;
    deps = Tree.deps_of tree;
    modules = Tree.modules_of tree;
  }

let from_java (scope : scope) fname = Repo.pom_of_java fname |> from_pom scope
