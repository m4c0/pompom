(* FIXME: "t" is actually the "resolvable scope", not the scope in POM. That's confusing *)
type t = Compile | Test | Runtime

let transitive_of set tr =
  let s = Option.value ~default:"compile" set in
  let t = Option.value ~default:"compile" tr in
  match (s, t) with
  | _, "compile" -> Some s
  | "compile", "runtime" | "runtime", "runtime" -> Some "runtime"
  | "provided", "runtime" -> Some "provided"
  | "test", "runtime" -> Some "test"
  | _, _ -> None

let matches (tt : t) (scope : string) =
  match (tt, scope) with
  | Compile, "compile"
  | Test, "compile"
  | Test, "provided"
  | Test, "test"
  | Runtime, "compile"
  | Runtime, "provided"
  | Runtime, "runtime" ->
      true
  | _, _ -> false
