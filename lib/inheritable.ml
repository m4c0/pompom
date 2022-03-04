type 'a t = 'a option

let value (tt : 'a t) ~(default : unit -> 'a) : 'a =
  match tt with Some v -> v | None -> default ()

let get (tt : 'a t) ~(default : unit -> 'a option) ~(label : string) : 'a =
  value tt ~default:(fun () ->
      match default () with
      | Some p -> p
      | None -> Errors.fail label "missing value")

let of_option (tt : 'a option) : 'a t = tt
