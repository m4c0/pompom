  $ ../xml.exe yet-another-db sql-3 3.0
  $ ../xml.exe sleeper core 1.0 <<EOF
  >   <dependencies>
  >     <dependency>
  >       <groupId>db</groupId>
  >       <artifactId>sql-1</artifactId>
  >       <version>1</version>
  >       <optional>true</optional>
  >     </dependency>
  >     <dependency>
  >       <groupId>other-db</groupId>
  >       <artifactId>sql-2</artifactId>
  >       <version>2</version>
  >       <optional>true</optional>
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
  >       <groupId>sleeper</groupId>
  >       <artifactId>core</artifactId>
  >       <version>1.0</version>
  >     </dependency>
  >     <dependency>
  >       <groupId>yet-another-db</groupId>
  >       <artifactId>sql-3</artifactId>
  >       <version>3.0</version>
  >       <optional>true</optional>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

According to Maven docs, optional dependencies are not pulled transitively.

  $ ../pomdump.exe -j Test.java
  id: got:deps-0
  deps:
    sleeper:core-1.0
    yet-another-db:sql-3-3.0
  modules:
