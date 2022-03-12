  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>got</groupId>
  >   <artifactId>deps</artifactId>
  >   <version>0</version>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>invalid</artifactId>
  >       <version>99</version>
  >       <optional>true</optional>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ../pomdump.exe -j Test.java
  id: got:deps-0
  deps:
  modules:
