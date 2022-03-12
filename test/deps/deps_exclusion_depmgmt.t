  $ ../xml.exe dep one 1.0 <<EOF
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one-broken</artifactId>
  >     </dependency>
  >   </dependencies>
  > EOF

  $ ../xml.exe project parent 1 <<EOF
  >   <dependencyManagement>
  >     <dependencies>
  >       <dependency>
  >         <groupId>dep</groupId>
  >         <artifactId>one</artifactId>
  >         <version>1.0</version>
  >         <exclusions>
  >           <exclusion>
  >             <groupId>dep</groupId>
  >             <artifactId>one-broken</artifactId>
  >           </exclusion>
  >         </exclusions>
  >       </dependency>
  >     </dependencies>
  >   </dependencyManagement>
  > EOF

  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <parent>
  >     <groupId>project</groupId>
  >     <artifactId>parent</artifactId>
  >     <version>1</version>
  >   </parent>
  >   <artifactId>main</artifactId>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one</artifactId>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ../pomdump.exe -j Test.java
  id: project:main-1
  deps:
    dep:one-1.0
  modules:
