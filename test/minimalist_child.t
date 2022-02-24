  $ ./xml.exe iam parent 1 <<EOF
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one</artifactId>
  >       <version>9</version>
  >     </dependency>
  >   </dependencies>
  > EOF

  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <parent>
  >     <groupId>iam</groupId>
  >     <artifactId>parent</artifactId>
  >     <version>1</version>
  >   </parent>
  >   <artifactId>world</artifactId>
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java -m repo
  id: iam:world-1
  deps:
    dep:one-9
  modules:
