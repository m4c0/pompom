type t

val apply_props : Properties.t -> t -> t
val classifier_of : t -> string option
val exclusions_of : t -> (string * string) Seq.t
val filename_of : t -> string
val id_of : t -> string * string * string
val is_bom : t -> bool
val is_optional : t -> bool
val of_parsed : t Depmap.t -> Dependency.t -> t
val to_mvn_str : t -> string
val unique_key_of : t -> string * string * string * string option
