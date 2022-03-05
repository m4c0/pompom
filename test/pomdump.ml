let () =
  let java = ref "" in
  let speclist =
    [
      ( "-j",
        Arg.Set_string java,
        "Path to a Java source. POM will be infered from that." );
    ]
  in
  let anon_fn x = failwith (x ^ ": invalid option") in
  let usage_msg = Sys.argv.(0) ^ " -j <path-to-java>" in
  Arg.parse speclist anon_fn usage_msg;
  if !java = "" then failwith "Missing input";

  let print_indent i str =
    print_string i;
    print_endline str
  in
  let print indent (group, artifact, version) =
    Printf.printf "%s%s:%s-%s\n" indent group artifact version
  in
  let printobj indent (p : Pompom.t) =
    let ni = "  " ^ indent in
    print_string indent;
    print_string "id: ";
    print "" (Pompom.id_of p);

    print_indent indent "deps:";
    Pompom.deps_seq p |> Seq.iter (print ni);

    print_indent indent "modules:";
    Pompom.modules_seq p |> Seq.iter (print_indent ni)
  in
  try Pompom.from_java Compile !java |> printobj "" with
  | Failure x -> print_endline ("[FAILURE] " ^ x)
  | Sys_error x -> print_endline ("[SYSERR] " ^ x)
