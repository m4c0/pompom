  $ ./xml.exe dep one 9
  $ ./xml.exe iam parent 1 <<EOF
  >   <dependencyManagement>
  >     <dependencies>
  >       <dependency>
  >         <groupId>dep</groupId>
  >         <artifactId>one</artifactId>
  >         <version>9</version>
  >       </dependency>
  >     </dependencies>
  >   </dependencyManagement>
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
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one</artifactId>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java
  id: iam:world-1
  deps:
    dep:one-9
  modules:
