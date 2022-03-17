type t

val deps_of : t -> t Seq.t
val node_of : t -> Efdep.t
val iter : Scopes.t -> Efpom.t -> t Seq.t
val resolve : Scopes.t -> Efpom.t -> Efpom.id Seq.t
