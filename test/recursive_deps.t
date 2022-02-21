  $ mkdir -p repo/iam/grampa/2

  $ cat > repo/iam/grampa/2/grampa-2.pom <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>iam</groupId>
  >   <artifactId>grampa</artifactId>
  >   <version>2</version>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one</artifactId>
  >       <version>9</version>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ mkdir -p repo/iam/parent/1

  $ cat > repo/iam/parent/1/parent-1.pom <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <parent>
  >     <groupId>iam</groupId>
  >     <artifactId>grampa</artifactId>
  >     <version>2</version>
  >   </parent>
  >   <groupId>iam</groupId>
  >   <artifactId>parent</artifactId>
  >   <version>1</version>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>two</artifactId>
  >       <version>8</version>
  >     </dependency>
  >   </dependencies>
  > </project>
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
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java -m repo
  id: iam:world-1
  deps:
    dep:two-8
    dep:one-9
