  $ ./xml.exe iam grampa 2 <<EOF
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one</artifactId>
  >       <version>9</version>
  >     </dependency>
  >   </dependencies>
  > EOF

  $ ./xml.exe iam parent 1 <<EOF
  >   <parent>
  >     <groupId>iam</groupId>
  >     <artifactId>grampa</artifactId>
  >     <version>2</version>
  >   </parent>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>two</artifactId>
  >       <version>8</version>
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
    dep:two-8
