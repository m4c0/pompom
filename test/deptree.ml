module Efpom = Pompom.Impl_EffectivePom
module Tree = Pompom.Impl_Tree

let dump_id i (g, a, v) cl sc =
  Printf.printf "%s%s:%s:%s:%s:%s" i g a cl v sc;
  match sc with
  | "" -> print_newline ()
  | x ->
      print_string ":";
      print_endline x

let rec rec_dump i cl (tree : Tree.t) =
  let node = tree.node in
  dump_id i node.id cl node.scope;
  try Seq.iter (fun d -> rec_dump (i ^ "  ") cl d) tree.deps
  with _ -> Printf.printf "%s  failed\n" i

let () =
  let fn = Array.get Sys.argv 1 in
  let pom = Efpom.from_pom fn in
  let cl = "jar" in
  dump_id "" (Efpom.id_of pom) cl "";
  Tree.build_tree_of_pom pom
  |> Seq.map (fun (t, _) -> t)
  |> Seq.iter (rec_dump "  " cl)
