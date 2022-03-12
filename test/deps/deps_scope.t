  $ ../xml.exe dep three 4.0
  $ ../xml.exe dep two 3.0 <<EOF
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>three</artifactId>
  >       <version>4.0</version>
  >     </dependency>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>also-prunned</artifactId>
  >       <scope>test</scope>
  >     </dependency>
  >   </dependencies>
  > EOF

  $ ../xml.exe dep one 2.0 <<EOF
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>two</artifactId>
  >       <version>3.0</version>
  >     </dependency>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>prunned-too</artifactId>
  >       <scope>test</scope>
  >     </dependency>
  >   </dependencies>
  > EOF

  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>group</groupId>
  >   <artifactId>art</artifactId>
  >   <version>1.0</version>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one</artifactId>
  >       <version>2.0</version>
  >     </dependency>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>prunned</artifactId>
  >       <scope>test</scope>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ../pomdump.exe -j Test.java
  id: group:art-1.0
  deps:
    dep:one-2.0
    dep:two-3.0
    dep:three-4.0
  modules:
