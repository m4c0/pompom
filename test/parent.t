  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <parent>
  >     <groupId>iam</groupId>
  >     <artifactId>parent</artifactId>
  >     <version>1</version>
  >   </parent>
  >   <groupId>hello</groupId>
  >   <artifactId>world</artifactId>
  >   <version>1.0</version>
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java -m repo
  Fatal error: exception Sys_error("repo/iam/parent/1/parent-1.pom: No such file or directory")
  [2]

  $ mkdir -p repo/iam/parent/1

  $ cat > repo/iam/parent/1/parent-1.pom <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <parent>
  >     <groupId>iam</groupId>
  >     <artifactId>grampa</artifactId>
  >     <version>2</version>
  >   </parent>
  >   <groupId>iam</groupId>
  >   <artifactId>parent</artifactId>
  >   <version>1</version>
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java -m repo
  Fatal error: exception Sys_error("repo/iam/grampa/2/grampa-2.pom: No such file or directory")
  [2]

  $ mkdir -p repo/iam/grampa/2

  $ cat > repo/iam/grampa/2/grampa-2.pom <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>iam</groupId>
  >   <artifactId>grampa</artifactId>
  >   <version>2</version>
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java -m repo
  parent:
    parent:
      parent:
      id: iam:grampa-2
      deps:
    id: iam:parent-1
    deps:
  id: hello:world-1.0
  deps:
