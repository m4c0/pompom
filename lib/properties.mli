type t

val apply : t Seq.t -> string -> string

val of_id : string * string * string -> t Seq.t
val of_seq : (string * string) Seq.t -> t Seq.t
