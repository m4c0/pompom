  $ ../xml.exe dep two 3.0
  $ ../xml.exe dep one 2.0 <<EOF
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>two</artifactId>
  >       <version>3.0</version>
  >     </dependency>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>prunned</artifactId>
  >       <version>6.9</version>
  >       <scope>test</scope>
  >     </dependency>
  >   </dependencies>
  > EOF

  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>group</groupId>
  >   <artifactId>art</artifactId>
  >   <version>1.0</version>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one</artifactId>
  >       <version>2.0</version>
  >       <scope>test</scope>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ../pomdump.exe -j Test.java -t
  id: group:art-1.0
  deps:
    dep:one-2.0
    dep:two-3.0
  modules:
