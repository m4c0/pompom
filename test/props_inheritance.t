  $ ./xml.exe using bom v
  $ ./xml.exe using parent 1.0 <<EOF
  > <properties><parent-prop>v</parent-prop></properties>
  > <dependencyManagement>
  >   <dependencies>
  >     <dependency>
  >       <groupId>from-parent</groupId>
  >       <artifactId>using-dep-mgmt</artifactId>
  >       <version>\${parent-prop}</version>
  >     </dependency>
  >     <dependency>
  >       <groupId>using</groupId>
  >       <artifactId>bom</artifactId>
  >       <version>\${parent-prop}</version>
  >       <scope>import</scope>
  >       <type>pom</type>
  >     </dependency>
  >   </dependencies>
  > </dependencyManagement>
  > <dependencies>
  >   <dependency>
  >     <groupId>from-parent</groupId>
  >     <artifactId>using-child-prop</artifactId>
  >     <version>\${child-prop}</version>
  >   </dependency>
  > </dependencies>
  > EOF

  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <parent>
  >     <groupId>using</groupId>
  >     <artifactId>parent</artifactId>
  >     <version>1.0</version>
  >   </parent>
  >   <artifactId>props</artifactId>
  >   <properties><child-prop>v</child-prop></properties>
  >   <dependencies>
  >     <dependency>
  >       <groupId>from-parent</groupId>
  >       <artifactId>using-dep-mgmt</artifactId>
  >     </dependency>
  >     <dependency>
  >       <groupId>from-child</groupId>
  >       <artifactId>using-parent-prop</artifactId>
  >       <version>\${parent-prop}</version>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java -m repo
  id: using:props-1.0
  deps:
    from-child:using-parent-prop-v
    from-parent:using-child-prop-v
    from-parent:using-dep-mgmt-v
