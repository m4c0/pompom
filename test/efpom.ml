module Efdep = Pompom.Impl_EffectiveDep
module Efpom = Pompom.Impl_EffectivePom

let print_id (g, a, v) = Printf.printf "%s:%s:%s" g a v

let print_id_lbl lbl id =
  print_string lbl;
  print_string ": ";
  print_id id;
  print_newline ()

let print_prop (k, v) = Printf.printf "  %s: %s\n" k v
let print_excl (g, a) = Printf.printf "  excludes %s:%s\n" g a

let print_depmgmt (d : Efdep.t) =
  print_string "- ";
  Efdep.to_mvn_str d |> print_endline;
  Efdep.exclusions_of d |> Seq.iter print_excl;
  Efdep.classifier_of d |> Option.iter (Printf.printf "  classifier %s\n");
  if Efdep.is_optional d then print_endline "  optional"

let () =
  let pom = Efpom.from_pom (Array.get Sys.argv 1) in
  print_id_lbl "id" (Efpom.id_of pom);
  Option.iter (print_id_lbl "parent") (Efpom.parent_of pom);
  print_endline "properties:";
  Seq.iter print_prop (Efpom.properties_of pom);
  print_endline "depmgmt:";
  Seq.iter print_depmgmt (Efpom.depmgmt_of pom);
  print_endline "dependencies:";
  Seq.iter print_depmgmt (Efpom.deps_of pom)
