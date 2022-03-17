  $ ../xml.exe deps b 1.0 <<EOF
  > <dependencies>
  >   <dependency>
  >     <groupId>broken</groupId>
  >     <artifactId>one</artifactId>
  >     <version>1.0</version>
  >   </dependency>
  >   <dependency>
  >     <groupId>broken</groupId>
  >     <artifactId>two</artifactId>
  >     <version>1.0</version>
  >   </dependency>
  > </dependencies>

  $ ../xml.exe deps a 1.0 <<EOF
  > <dependencies>
  >   <dependency>
  >     <groupId>deps</groupId>
  >     <artifactId>b</artifactId>
  >     <version>1.0</version>
  >     <exclusions>
  >       <exclusion>
  >         <groupId>broken</groupId>
  >         <artifactId>two</artifactId>
  >       </exclusion>
  >     </exclusions>
  >   </dependency>
  > </dependencies>

  $ cat > pom.xml <<EOF
  > <project>
  >   <groupId>project</groupId>
  >   <artifactId>art</artifactId>
  >   <version>1.0</version>
  >   <dependencyManagement>
  >     <dependencies>
  >       <dependency>
  >         <groupId>deps</groupId>
  >         <artifactId>b</artifactId>
  >         <version>1.0</version>
  >         <exclusions>
  >           <exclusion>
  >             <groupId>broken</groupId>
  >             <artifactId>one</artifactId>
  >           </exclusion>
  >         </exclusions>
  >       </dependency>
  >     </dependencies>
  >   </dependencyManagement>
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
