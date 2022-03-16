(lang dune 2.9)
(name pompom)
(version 1.0.0)

(cram enable)
(generate_opam_files true)

(source (github m4c0/pompom))
(license MIT)
(authors "Eduardo Costa")
(maintainers m4c0@users.noreply.github.com)

(package
 (name pompom)
 (synopsis "")
 (description "")
 (depends
  (landmarks-ppx (and :dev (>= 1.4)))
  (xmelly (> 1.0.1))))
