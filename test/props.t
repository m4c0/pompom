  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>using</groupId>
  >   <artifactId>props</artifactId>
  >   <version>1.0</version>
  >   <properties>
  >     <dep.one.ver>2.2</dep.one.ver>
  >     <empty.prop></empty.prop>
  >   </properties>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one</artifactId>
  >       <version>\${dep.one.ver}</version>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java -m repo
  id: using:props-1.0
  deps:
    dep:one-2.2
