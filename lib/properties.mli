type t

val apply : t -> string -> string
val merge_left : t -> t -> t
val merge_right : t -> t -> t
val of_id : string * string * string -> t
val of_seq : (string * string) Seq.t -> t
val resolve : t -> t
val to_seq : t -> (string * string) Seq.t
