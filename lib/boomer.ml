let read_bom (d : Pom.dep) : Parser.t =
  let g = d.ga.group in
  let a = d.ga.artifact in
  let v =
    match d.version with
    | Some vv -> vv
    | None -> Printf.sprintf "missing version for %s:%s" g a |> failwith
  in
  Repo.asset_fname "pom" g a v |> Inheritor.parse_and_merge

let rec merge_boms (d : Pom.dep) : Pom.dep Seq.t =
  if Pom.is_bom d then
    let bom = read_bom d in
    Seq.map merge_boms bom.dep_mgmt |> Seq.concat
  else Seq.return d
