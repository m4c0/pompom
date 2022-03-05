type t

val id_of : t -> Pom.id
val deps_seq : t -> Pom.id Seq.t
val modules_seq : t -> string Seq.t
val build_tree : Scopes.t -> string -> t
