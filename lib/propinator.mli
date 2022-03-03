type t

val of_seq : (string * string) Seq.t -> t
val apply_to_dep : t -> Parser.t -> Pom.dep -> Pom.dep
