type node
type t

val of_dep_seq : Dependency.t Seq.t -> t
val find : Dependency.t -> t -> node Seq.t
val exclusions_of : node -> Dependency.ga Seq.t
val version_of : node -> string Seq.t
