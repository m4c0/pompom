type t

val id_of : t -> Efpom.id
val deps_seq : t -> Efpom.id Seq.t
val modules_seq : t -> string Seq.t
val build_tree : Scopes.t -> string -> t
