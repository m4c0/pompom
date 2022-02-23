  $ ./xml.exe dep two 8
  $ ./xml.exe dep one 9 <<EOF
  >   <dependencyManagement>
  >     <dependencies>
  >       <dependency>
  >         <groupId>dep</groupId>
  >         <artifactId>two</artifactId>
  >         <version>8</version>
  >       </dependency>
  >     </dependencies>
  >   </dependencyManagement>
  > EOF

  $ ./xml.exe iam parent 1 <<EOF
  >   <dependencyManagement>
  >     <dependencies>
  >       <dependency>
  >         <groupId>dep</groupId>
  >         <artifactId>one</artifactId>
  >         <version>9</version>
  >         <scope>import</scope>
  >         <type>pom</type>
  >       </dependency>
  >     </dependencies>
  >   </dependencyManagement>
  > EOF

  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <parent>
  >     <groupId>iam</groupId>
  >     <artifactId>parent</artifactId>
  >     <version>1</version>
  >   </parent>
  >   <artifactId>world</artifactId>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>two</artifactId>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java -m repo
  id: iam:world-1
  deps:
    dep:two-8
