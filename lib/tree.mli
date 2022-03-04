type t

val id_of : t -> string * string * string
val deps_seq : t -> (string * string * string) Seq.t
val modules_seq : t -> string Seq.t
val build_tree : Scopes.t -> string -> t
