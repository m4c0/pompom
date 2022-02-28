type t = Compile | Test | Runtime

let scope_list = function
  | Compile -> ["compile"]
  | Runtime -> ["compile";"provided"]
  | Test -> ["compile";"test";"provided"]

let transitive_of _ = Compile (* TODO: this might be wrong *)

let matches (tt : t) (scope : string option) =
  let scopes = scope_list tt in
  Option.value ~default:"compile" scope
  |> String.equal
  |> (Fun.flip List.find_opt) scopes
  |> Option.is_some

