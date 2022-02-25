  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>hello</groupId>
  >   <artifactId>world</artifactId>
  >   <version>1.0</version>
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java
  id: hello:world-1.0
  deps:
  modules:
