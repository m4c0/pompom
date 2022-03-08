module Efpom = Pompom.Impl_EffectivePom

let print_id (g, a, v) = Printf.printf "%s:%s-%s" g a v

let print_id_lbl lbl id =
  print_string lbl;
  print_string ": ";
  print_id id;
  print_newline ()

let () =
  let pom = Efpom.from_java "src/Test.java" in
  print_id_lbl "id" (Efpom.id_of pom);
  Option.iter (print_id_lbl "parent") (Efpom.parent_of pom)
