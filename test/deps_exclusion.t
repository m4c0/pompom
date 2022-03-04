  $ ./xml.exe dep one 1.0 <<EOF
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one-broken</artifactId>
  >     </dependency>
  >   </dependencies>
  > EOF

  $ ./xml.exe dep two 2.0 <<EOF
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>two-broken</artifactId>
  >       <version>\${broken}</version>
  >     </dependency>
  >   </dependencies>
  > EOF

  $ ./xml.exe project parent 1 <<EOF
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>two</artifactId>
  >       <version>2.0</version>
  >       <exclusions>
  >         <groupId>dep</groupId>
  >         <artifactId>two-broken</artifactId>
  >       </exclusions>
  >     </dependency>
  >   </dependencies>
  > EOF

  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <parent>
  >     <groupId>project</groupId>
  >     <artifactId>parent</artifactId>
  >     <version>1</version>
  >   </parent>
  >   <artifactId>main</artifactId>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one</artifactId>
  >       <version>1.0</version>
  >       <exclusions>
  >         <groupId>dep</groupId>
  >         <artifactId>one-broken</artifactId>
  >       </exclusions>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java
  id: project:main-1
  deps:
    dep:two-2.0
    dep:one-1.0
  modules:
