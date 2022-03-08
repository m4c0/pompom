module Efpom = Pompom.Impl_EffectivePom

let print_id (g, a, v) = Printf.printf "%s:%s-%s" g a v

let print_id_lbl lbl id =
  print_string lbl;
  print_string ": ";
  print_id id;
  print_newline ()

let print_prop (k, v) =
  print_string "  ";
  print_string k;
  print_string ": ";
  print_string v;
  print_newline ()

let () =
  let pom = Efpom.from_java (Array.get Sys.argv 1) in
  print_id_lbl "id" (Efpom.id_of pom);
  Option.iter (print_id_lbl "parent") (Efpom.parent_of pom);
  print_endline "properties:";
  Seq.iter (print_prop) (Efpom.properties_of pom);
