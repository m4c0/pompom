module Efpom = Pompom.Impl_EffectivePom

let print_id (g, a, v) = Printf.printf "%s:%s:%s" g a v

let print_id_lbl lbl id =
  print_string lbl;
  print_string ": ";
  print_id id;
  print_newline ()

let print_prop (k, v) = Printf.printf "  %s: %s\n" k v
let print_excl (g, a) = Printf.printf "  excludes %s:%s\n" g a

let print_depmgmt (d : Efpom.dep) =
  print_string "- ";
  print_id d.id;
  Printf.printf ":%s:%s" d.tp d.scope;
  print_newline ();
  Seq.iter print_excl d.exclusions;
  Option.iter (Printf.printf "  classifier %s\n") d.classifier;
  if d.optional then print_endline "  optional"

let () =
  let pom = Efpom.from_java (Array.get Sys.argv 1) in
  print_id_lbl "id" (Efpom.id_of pom);
  Option.iter (print_id_lbl "parent") (Efpom.parent_of pom);
  print_endline "properties:";
  Seq.iter print_prop (Efpom.properties_of pom);
  print_endline "depmgmt:";
  Seq.iter print_depmgmt (Efpom.depmgmt_of pom);
  print_endline "dependencies:";
  Seq.iter print_depmgmt (Efpom.deps_of pom)
