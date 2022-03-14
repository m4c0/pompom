type t

val deps_of : t -> t Seq.t
val node_of : t -> Efdep.t
val iter : Scopes.t -> (t -> unit) -> Efpom.t -> unit
val resolve : Scopes.t -> Efpom.t -> Efpom.id Seq.t
