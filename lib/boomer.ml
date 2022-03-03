let read_bom (d : Pom.dep) : Parser.t =
  let g = d.ga.group in
  let a = d.ga.artifact in
  let v =
    match d.version with
    | Some vv -> vv
    | None -> Printf.sprintf "missing version for %s:%s" g a |> failwith
  in
  Repo.asset_fname "pom" g a v |> Inheritor.parse_and_merge

let rec merge_boms (props : Propinator.t) (p : Parser.t) (d : Pom.dep) :
    Pom.dep Seq.t =
  if Pom.is_bom d then
    let rd = Propinator.apply_to_dep props p d in
    let bom = read_bom rd in
    Seq.flat_map (merge_boms props p) bom.dep_mgmt
  else Seq.return d

let build_bom (p : Parser.t) =
  let props = Propinator.of_seq p.props in
  let split (d : Pom.dep) = (d.ga, d) in
  Seq.flat_map (merge_boms props p) p.dep_mgmt |> Seq.map split |> Ga_map.of_seq
