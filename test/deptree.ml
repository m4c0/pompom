module Efpom = Pompom.Impl_EffectivePom
module Tree = Pompom.Impl_Tree

let dump i (tree : Tree.t) =
  let pom = tree.pom in
  let (g, a, v) = Efpom.id_of pom in
  Printf.printf "%s%s:%s-%s\n" i g a v

let rec rec_dump i (tree : Tree.t) =
  dump i tree;
  try Seq.iter (fun d -> rec_dump (i ^ "  ") d) tree.deps
  with _ -> Printf.printf "%s  failed\n" i

let () =
  let fn = Array.get Sys.argv 1 in
  let pom = Efpom.from_pom fn in
  let scope : Pompom.scope = Compile in
  let tree = Tree.build_tree {scope} pom in
  rec_dump "" tree
