type t

val deps_of : t -> t Seq.t
val node_of : t -> Efdep.t
val iter : (t -> unit) -> Efpom.t -> unit
val resolve : Efpom.t -> Efpom.id Seq.t
