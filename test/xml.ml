let triplet =
  match Sys.argv with
  | [| _; grp; art; ver |] -> (grp, art, ver)
  | _ -> failwith "missing args"

let rec mkdirs fld =
  let dir = Filename.dirname fld in
  if dir <> "." then mkdirs dir;
  try Sys.mkdir fld 0o777 with Sys_error _ -> ()

let rec passthru oc =
  try
    let line = read_line () in
    output_string oc line;
    output_string oc "\n";
    passthru oc
  with End_of_file -> ()

let () =
  let grp, art, ver = triplet in
  let home = Sys.getenv "HOME" in
  let fld =
    [ ".m2"; "repository"; grp; art; ver ]
    |> List.fold_left Filename.concat home
  in
  let pom_name = Printf.sprintf "%s-%s.pom" art ver in
  let pom = Filename.concat fld pom_name in
  mkdirs fld;
  let xml =
    [
      "<?xml version=\"1.0\"?>\n";
      "<project>";
      "<groupId>";
      grp;
      "</groupId>";
      "<artifactId>";
      art;
      "</artifactId>";
      "<version>";
      ver;
      "</version>";
    ]
  in
  let oc = open_out pom in
  List.iter (output_string oc) xml;
  passthru oc;
  output_string oc "</project>"
