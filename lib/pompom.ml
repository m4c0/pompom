type id = string * string * string
type t = { id : id; deps : id Seq.t; modules : string Seq.t }
type scope = Scopes.t

module Impl_EffectiveDep = Efdep
module Impl_EffectivePom = Efpom
module Impl_Tree = Tree

let id_of (tt : t) : id = tt.id
let deps_seq (tt : t) : id Seq.t = tt.deps
let modules_seq (tt : t) : string Seq.t = tt.modules

let asset_fname (ext : string) ((g, a, v) : id) : string =
  Repo.asset_fname ext g a v

let from_pom (scope : scope) (fname : string) : t =
  let pom = Efpom.from_pom fname in
  {
    id = Efpom.id_of pom;
    deps = Tree.resolve scope pom;
    modules = Efpom.modules_of pom;
  }

let from_java (scope : scope) fname = Repo.pom_of_java fname |> from_pom scope
let from_mvn_str (scope : scope) name = Repo.pom_of_mvn_str name |> from_pom scope
