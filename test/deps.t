  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>got</groupId>
  >   <artifactId>deps</artifactId>
  >   <version>0</version>
  >   <dependencies/>
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java
  id: got:deps-0
  deps:
  modules:

  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>got</groupId>
  >   <artifactId>deps</artifactId>
  >   <version>0</version>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one</artifactId>
  >       <version>99</version>
  >     </dependency>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>two</artifactId>
  >       <version>98</version>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java
  id: got:deps-0
  deps:
    dep:one-99
    dep:two-98
  modules:
