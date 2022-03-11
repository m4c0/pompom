type t = { node : Efpom.dep; deps : t Seq.t }

module Map = Map.Make (struct
  type t = string * string

  let compare (ga, aa) (gb, ab) =
    match String.compare ga gb with 0 -> String.compare aa ab | x -> x
end)

let rec build_tree (node : Efpom.dep) : t =
  let deps = Efpom.from_dep node |> Efpom.deps_of |> Seq.map build_tree in
  { node; deps }

let rec fold_deps (deps : t Seq.t) =
  let dd =
    Seq.map (fun t -> t.node.id) deps
    |> Seq.map (fun (g, a, v) -> ((g, a), v))
    |> Map.of_seq
  in
  let dr = Seq.map (fun t -> t.deps) deps |> Seq.map fold_deps in
  let fn = Map.merge (fun _ a b -> match a with None -> b | _ -> a) in
  Seq.fold_left fn dd dr

let resolve (pom : Efpom.t) =
  Efpom.deps_of pom |> Seq.map build_tree |> fold_deps |> Map.to_seq
  |> Seq.map (fun ((g, a), v) -> (g, a, v))
