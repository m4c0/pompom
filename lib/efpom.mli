type id = string * string * string
type dep = {
  id : id;
  exclusions : (string * string) Seq.t;
  classifier : string option;
  optional : bool;
  tp : string option;
}
type t

val depmgmt_of : t -> dep Seq.t
val id_of : t -> id
val parent_of : t -> id option
val properties_of : t -> (string * string) Seq.t
val from_pom : string -> t
val from_java : string -> t
