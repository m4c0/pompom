  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>cdata</groupId>
  >   <artifactId>everywhere</artifactId>
  >   <version>0</version>
  >   <properties>
  >     <cdata><![CDATA[this is cdata]]></cdata>
  >   </properties>
  >   <dependencies>
  >     <dependency>
  >       <groupId>cdata</groupId>
  >       <artifactId>dep</artifactId>
  >       <version><![CDATA[version]]></version>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF
  $ ./pomdump.exe -j Test.java -m repo
  id: cdata:everywhere-0
  deps:
    cdata:dep-version
