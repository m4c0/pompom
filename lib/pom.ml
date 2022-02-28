type ga = {
  group: string;
  artifact: string;
}
type id = {
  ga : ga;
  version : string;
}

let tuple_of_id ({ ga = { group; artifact }; version } : id) = (group, artifact, version)
