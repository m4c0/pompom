type t = Compile | Test | Runtime

let scope_list = function
  | Compile -> [ "compile" ]
  | Runtime -> [ "compile"; "provided" ]
  | Test -> [ "compile"; "test"; "provided" ]

let transitive_of _ = Compile (* TODO: this might be wrong *)

let matches (tt : t) (scope : string) =
  scope_list tt |> List.find_opt (String.equal scope) |> Option.is_some
