let parent_merger _ a b =
  match (a, b) with
  | None, None -> None
  | Some aa, None -> Some aa
  | None, Some bb -> Some bb
  | Some _, Some bb -> Some bb
