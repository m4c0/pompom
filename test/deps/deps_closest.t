  $ ../xml.exe dep one 1 <<EOF
  > <dependencies>
  >   <dependency>
  >     <groupId>dep</groupId>
  >     <artifactId>two</artifactId>
  >     <version>9</version>
  >   </dependency>
  > </dependencies>
  > EOF

  $ ../xml.exe dep two 2
  $ ../xml.exe dep three 3
  $ ../xml.exe owner parent 9 <<EOF
  > <dependencies>
  >   <dependency>
  >     <groupId>dep</groupId>
  >     <artifactId>one</artifactId>
  >     <version>9</version>
  >   </dependency>
  > </dependencies>
  > EOF

  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <parent>
  >     <groupId>owner</groupId>
  >     <artifactId>parent</artifactId>
  >     <version>9</version>
  >   </parent>
  >   <artifactId>project</artifactId>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one</artifactId>
  >       <version>1</version>
  >     </dependency>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>two</artifactId>
  >       <version>2</version>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ../pomdump.exe -j Test.java
  id: owner:project-9
  deps:
    dep:one-1
    dep:two-2
  modules:
