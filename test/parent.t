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

  $ ./pomdump.exe -j Test.java
  Fatal error: exception Sys_error("./.m2/repository/iam/parent/1/parent-1.pom: No such file or directory")
  [2]

  $ ./xml.exe iam parent 1 <<EOF
  >   <parent>
  >     <groupId>iam</groupId>
  >     <artifactId>grampa</artifactId>
  >     <version>2</version>
  >   </parent>
  > EOF

  $ ./pomdump.exe -j Test.java
  Fatal error: exception Sys_error("./.m2/repository/iam/grampa/2/grampa-2.pom: No such file or directory")
  [2]

  $ ./xml.exe iam grampa 2

  $ ./pomdump.exe -j Test.java
  id: hello:world-1.0
  deps:
  modules:
