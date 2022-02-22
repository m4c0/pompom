  $ mkdir -p repo/dep/one/9

  $ cat > repo/dep/one/9/one-9.pom <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>dep</groupId>
  >   <artifactId>one</artifactId>
  >   <version>9</version>
  >   <dependencyManagement>
  >     <dependencies>
  >       <dependency>
  >         <groupId>dep</groupId>
  >         <artifactId>two</artifactId>
  >         <version>8</version>
  >       </dependency>
  >     </dependencies>
  >   </dependencyManagement>
  > </project>
  > EOF

  $ mkdir -p repo/dep/two/8

  $ cat > repo/dep/two/8/two-8.pom <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>dep</groupId>
  >   <artifactId>two</artifactId>
  >   <version>8</version>
  > </project>
  > EOF

  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>iam</groupId>
  >   <artifactId>world</artifactId>
  >   <version>1</version>
  >   <dependencyManagement>
  >     <dependencies>
  >       <dependency>
  >         <groupId>dep</groupId>
  >         <artifactId>one</artifactId>
  >         <version>8</version>
  >       </dependency>
  >     </dependencies>
  >   </dependencyManagement>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one</artifactId>
  >     </dependency>
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
    dep:one-9
    dep:two-8
