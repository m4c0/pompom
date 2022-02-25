  $ ./xml.exe dep three 97
  $ ./xml.exe dep two 98 <<EOF
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>three</artifactId>
  >       <version>97</version>
  >     </dependency>
  >   </dependencies>
  > EOF

  $ ./xml.exe dep one 99 <<EOF
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
  >   <groupId>got</groupId>
  >   <artifactId>deps</artifactId>
  >   <version>0</version>
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
  id: got:deps-0
  deps:
    dep:one-99
    dep:three-97
    dep:two-98
  modules:
