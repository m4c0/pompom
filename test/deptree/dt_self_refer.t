  $ ../xml.exe deps selfie 1.0 <<EOF
  > <dependencies>
  >   <dependency>
  >     <groupId>deps</groupId>
  >     <artifactId>selfie</artifactId>
  >     <version>1.0</version>
  >   </dependency>
  > </dependencies>

  $ cat > pom.xml <<EOF
  > <project>
  >   <groupId>project</groupId>
  >   <artifactId>art</artifactId>
  >   <version>1.0</version>
  >   <dependencies>
  >     <dependency>
  >       <groupId>deps</groupId>
  >       <artifactId>selfie</artifactId>
  >       <version>1.0</version>
  >     </dependency>
  >   </dependencies>
  > </project>

  $ ../deptree.exe pom.xml
  project:art:jar:1.0
    deps:selfie:jar:1.0:compile
