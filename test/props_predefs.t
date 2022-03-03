  $ ./xml.exe dep props 1.0
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
  >       <version>\${project.version}</version>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java
  id: using:props-1.0
  deps:
    dep:props-1.0
  modules:
