  $ ../xml.exe dep other 1.0.2.0
  $ ../xml.exe dep props 1.0.2.0 <<EOF
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>other</artifactId>
  >       <version>\${project.version}</version>
  >     </dependency>
  >   </dependencies>
  > EOF

  $ ../xml.exe using parent 2.0
  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <parent>
  >     <groupId>using</groupId>
  >     <artifactId>parent</artifactId>
  >     <version>2.0</version>
  >   </parent>
  >   <artifactId>props</artifactId>
  >   <version>1.0</version>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>\${project.artifactId}</artifactId>
  >       <version>\${project.version}.\${project.parent.version}</version>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ../pomdump.exe -j Test.java
  id: using:props-1.0
  deps:
    dep:props-1.0.2.0
    dep:other-1.0.2.0
  modules:
