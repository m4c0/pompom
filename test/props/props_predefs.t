  $ ../xml.exe dep other 1.0.0
  $ ../xml.exe dep props 1.0.0 <<EOF
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>other</artifactId>
  >       <version>\${project.version}</version>
  >     </dependency>
  >   </dependencies>
  > EOF

  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>using</groupId>
  >   <artifactId>props</artifactId>
  >   <version>1.0</version>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>\${project.artifactId}</artifactId>
  >       <version>\${project.version}.0</version>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ../pomdump.exe -j Test.java
  id: using:props-1.0
  deps:
    dep:props-1.0.0
    dep:other-1.0.0
  modules:
