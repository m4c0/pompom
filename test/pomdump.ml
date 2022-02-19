let () =
  let java = ref "" in
  let speclist = [("-j", Arg.Set_string java, "Path to a Java source. POM will be infered from that.")] in
  let anon_fn x = failwith (x ^ ": invalid option") in
  let usage_msg = Sys.argv.(0) ^ " -j <path-to-java>" in
  Arg.parse speclist anon_fn usage_msg;
  if !java = "" then failwith "Missing input";

  let print indent (group, artifact, version) =
    Printf.printf "%s%s:%s   %s\n" indent group artifact version
  in
  let rec printobj indent (p : Pompom.t) =
    let ni = "  " ^ indent in
    print_string indent;
    print_endline "parent:";
    Option.iter (printobj ni) p.parent;

    print_string indent;
    print_string "id: ";
    print "" p.id;

    print_string indent;
    print_endline "deps:";
    p.deps |> List.iter (print ni)
  in
  Pompom.from_java !java |> printobj ""
