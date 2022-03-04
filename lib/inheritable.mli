type 'a t

val get : 'a t -> default:(unit -> 'a option) -> label:string -> 'a
val value : 'a t -> default:(unit -> 'a) -> 'a
val of_option : 'a option -> 'a t
