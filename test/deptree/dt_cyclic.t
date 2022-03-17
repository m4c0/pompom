  $ ../xml.exe deps a 1.0 <<EOF
  > <dependencies>
  >   <dependency>
  >     <groupId>deps</groupId>
  >     <artifactId>b</artifactId>
  >     <version>1.0</version>
  >   </dependency>
  > </dependencies>

  $ ../xml.exe deps b 1.0 <<EOF
  > <dependencies>
  >   <dependency>
  >     <groupId>deps</groupId>
  >     <artifactId>c</artifactId>
  >     <version>1.0</version>
  >   </dependency>
  > </dependencies>

  $ ../xml.exe deps c 1.0 <<EOF
  > <dependencies>
  >   <dependency>
  >     <groupId>deps</groupId>
  >     <artifactId>b</artifactId>
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
  >       <artifactId>a</artifactId>
  >       <version>1.0</version>
  >     </dependency>
  >   </dependencies>
  > </project>

  $ ../deptree.exe pom.xml
  project:art:jar:1.0
    deps:a:jar:1.0:compile
      deps:b:jar:1.0:compile
        deps:c:jar:1.0:compile
