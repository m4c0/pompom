type t

val id_of : t -> Pom.id
val parent_of : t -> Pom.id option
val from_pom : string -> t
val from_java : string -> t
