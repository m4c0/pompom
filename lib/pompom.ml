type id = string * string * string
type t = { id : id; modules : string Seq.t }
type scope = Scopes.t

let id_of (tt : t) : id = tt.id
let deps_seq (_ : t) : id Seq.t = Seq.empty
let modules_seq (tt : t) : string Seq.t = tt.modules

let asset_fname (ext : string) ((g, a, v) : id) : string =
  Repo.asset_fname ext g a v

let from_pom (s : scope) (fname : string) : t =
  let tree = Tree.build_tree s fname in
  { id = tree.id; modules = tree.modules }

let from_java (scope : scope) fname =
  let rec pom_of fname =
    let pom = Filename.concat fname "pom.xml" in
    if Sys.file_exists pom then pom else fname |> Filename.dirname |> pom_of
  in
  pom_of fname |> from_pom scope
