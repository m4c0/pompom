type id = string * string * string
type t

val depmgmt_of : t -> Efdep.t Seq.t
val deps_of : t -> Efdep.t Seq.t
val id_of : t -> id
val modules_of : t -> string Seq.t
val parent_of : t -> id option
val properties_of : t -> (string * string) Seq.t
val from_dep : Efdep.t -> t
val from_pom : string -> t
val from_java : string -> t
val from_mvn_str : string -> t
