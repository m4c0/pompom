type ga = { group : string; artifact : string }

type dep = {
  ga : ga;
  version : string option;
  scope : string option;
  tp : string option;
  exclusions : ga Seq.t;
}

let is_bom (d : dep) = d.scope = Some "import" && d.tp = Some "pom"
