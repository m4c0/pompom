  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>group</groupId>
  >   <artifactId>art</artifactId>
  >   <version>1.0</version>
  >   <dependencyManagement>
  >     <dependencies>
  >       <dependency>
  >         <groupId>dep</groupId>
  >         <artifactId>one</artifactId>
  >         <version>1.0</version>
  >         <scope>test</scope>
  >       </dependency>
  >     </dependencies>
  >   </dependencyManagement>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one</artifactId>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ../pomdump.exe -j Test.java
  id: group:art-1.0
  deps:
  modules:
