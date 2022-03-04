let fail label msg = label ^ ": " ^ msg |> failwith
let fail_fn label msg () = fail label msg
