type id = string * string * string

type dep = {
  id : id;
  exclusions : (string * string) Seq.t;
  classifier : string option;
  optional : bool;
  scope : string;
  tp : string;
  is_bom : bool;
}

type t

val depmgmt_of : t -> dep Seq.t
val deps_of : t -> dep Seq.t
val id_of : t -> id
val modules_of : t -> string Seq.t
val parent_of : t -> id option
val properties_of : t -> (string * string) Seq.t
val from_dep : dep -> t
val from_pom : string -> t
val from_java : string -> t
