  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>got</groupId>
  >   <artifactId>mods</artifactId>
  >   <version>1</version>
  >   <modules>
  >     <module>ModA</module>
  >     <module>ModB</module>
  >   </modules>
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java -m repo
  id: got:mods-1
  deps:
  modules:
    ModA
    ModB

