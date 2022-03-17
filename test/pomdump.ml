let () =
  let java = ref "" in
  let pom = ref "" in
  let mvn_str = ref "" in
  let test_scope = ref false in
  let speclist =
    [
      ( "-j",
        Arg.Set_string java,
        "Path to a Java source. POM will be infered from that." );
      ("-p", Arg.Set_string pom, "Path to POM.");
      ( "-m",
        Arg.Set_string mvn_str,
        "Maven string (group:artifact:type:version)." );
      ("-t", Arg.Set test_scope, "Uses 'test' scope instead of 'compile'.");
    ]
  in
  let anon_fn x = failwith (x ^ ": invalid option") in
  let usage_msg = Sys.argv.(0) ^ " (-j <path-to-java> | -p <path-to-pom>)" in
  Arg.parse speclist anon_fn usage_msg;
  if !java = "" && !pom = "" && !mvn_str = "" then failwith "Missing input";

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
  try
    let p =
      if !mvn_str != "" then
        Pompom.from_mvn_str (if !test_scope then Test else Compile) !mvn_str
      else if !pom = "" then
        Pompom.from_java (if !test_scope then Test else Compile) !java
      else Pompom.from_pom (if !test_scope then Test else Compile) !pom
    in
    printobj "" p
  with
  | Failure x -> print_endline ("[FAILURE] " ^ x)
  | Sys_error x -> print_endline ("[SYSERR] " ^ x)
