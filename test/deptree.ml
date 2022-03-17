module Efdep = Pompom.Impl_EffectiveDep
module Efpom = Pompom.Impl_EffectivePom
module Tree = Pompom.Impl_Tree

let rec rec_dump i (tree : Tree.t) =
  let node = Tree.node_of tree in
  print_string i;
  print_endline (Efdep.to_mvn_str node);
  try Tree.deps_of tree |> Seq.iter (fun d -> rec_dump (i ^ "  ") d)
  with _ -> Printf.printf "%s  failed\n" i

let () =
  let fn = Array.get Sys.argv 1 in
  let pom = Efpom.from_pom fn in
  let g, a, v = Efpom.id_of pom in
  Printf.printf "%s:%s:jar:%s\n" g a v;
  Tree.iter Test pom |> Seq.iter (rec_dump "  ")
