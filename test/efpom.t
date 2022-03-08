  $ cat > pom.xml <<EOF
  > <project>
  >   <parent>
  >     <groupId>project</groupId>
  >     <artifactId>parent</artifactId>
  >     <version>1.0</version>
  >   </parent>
  >   <artifactId>child</artifactId>
  > </project>

  $ ./efpom.exe <<EOF
  id: project:child-1.0
  parent: project:parent-1.0
