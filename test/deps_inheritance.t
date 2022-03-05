  $ ./xml.exe prj grampa 1 <<EOF
  >   <groupId>prj</groupId>
  >   <artifactId>grampa</artifactId>
  >   <version>1</version>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>three</artifactId>
  >       <version>97</version>
  >     </dependency>
  >   </dependencies>
  > EOF

  $ ./xml.exe prj parent 1 <<EOF
  >   <parent>
  >     <groupId>prj</groupId>
  >     <artifactId>grampa</artifactId>
  >     <version>1</version>
  >   </parent>
  >   <artifactId>parent</artifactId>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>two</artifactId>
  >       <version>98</version>
  >     </dependency>
  >   </dependencies>
  > EOF

  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <parent>
  >     <groupId>prj</groupId>
  >     <artifactId>parent</artifactId>
  >     <version>1</version>
  >   </parent>
  >   <artifactId>child</artifactId>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one</artifactId>
  >       <version>99</version>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java
  id: prj:child-1
  deps:
    dep:one-99
    dep:two-98
    dep:three-97
  modules:
