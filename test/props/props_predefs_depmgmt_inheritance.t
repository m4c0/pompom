  $ ../xml.exe project dep 1.0
  $ ../xml.exe project parent 1.0 <<EOF
  > <dependencyManagement>
  >   <dependencies>
  >     <dependency>
  >       <groupId>\${project.groupId}</groupId>
  >       <artifactId>dep</artifactId>
  >       <version>\${project.version}</version>
  >     </dependency>
  >   </dependencies>
  > </dependencyManagement>

  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <parent>
  >     <groupId>project</groupId>
  >     <artifactId>parent</artifactId>
  >     <version>1.0</version>
  >   </parent>
  >   <artifactId>child</artifactId>
  >   <dependencies>
  >     <dependency>
  >       <groupId>\${project.groupId}</groupId>
  >       <artifactId>dep</artifactId>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ../pomdump.exe -j Test.java
  id: project:child-1.0
  deps:
    project:dep-1.0
  modules:
