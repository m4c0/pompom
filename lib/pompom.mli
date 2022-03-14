type id = string * string * string
type t
type scope = Scopes.t

module Impl_EffectiveDep = Efdep
module Impl_EffectivePom = Efpom
module Impl_Tree = Tree

val id_of : t -> id
val deps_seq : t -> id Seq.t
val modules_seq : t -> string Seq.t
val asset_fname : string -> id -> string
val from_pom : scope -> string -> t
val from_java : scope -> string -> t
