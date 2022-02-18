let () =
  let java = ref "" in
  let speclist = [("-j", Arg.Set_string java, "Path to a Java source. POM will be infered from that.")] in
  let anon_fn x = failwith (x ^ ": invalid option") in
  let usage_msg = Sys.argv.(0) ^ " -j <path-to-java>" in
  Arg.parse speclist anon_fn usage_msg;
  if !java = "" then failwith "Missing input";

  let p = Pompom.from_java !java in
  print_endline "parent:";
  print_endline p.parent.group;
  print_endline p.parent.artifact;
  print_endline p.parent.version;
  print_newline ();
