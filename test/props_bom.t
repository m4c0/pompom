  $ ./xml.exe dep one 2.0
  $ ./xml.exe dep two 2.1
  $ ./xml.exe dep bom 2.0 <<EOF
  > <properties><dep.version>2.1</dep.version></properties>
  > <dependencyManagement>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one</artifactId>
  >       <version>\${project.version}</version>
  >     </dependency>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>two</artifactId>
  >       <version>\${dep.version}</version>
  >     </dependency>
  >   </dependencies>
  > </dependencyManagement>
  > EOF

  $ cat > pom.xml <<EOF
  > <?xml version="1.0"?>
  > <project>
  >   <groupId>using</groupId>
  >   <artifactId>props</artifactId>
  >   <version>1.0</version>
  >   <properties><dep.bom.version>2.0</dep.bom.version></properties>
  >   <dependencyManagement>
  >     <dependencies>
  >       <dependency>
  >         <groupId>dep</groupId>
  >         <artifactId>bom</artifactId>
  >         <version>\${dep.bom.version}</version>
  >         <type>pom</type>
  >         <scope>import</scope>
  >       </dependency>
  >     </dependencies>
  >   </dependencyManagement>
  >   <dependencies>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>one</artifactId>
  >     </dependency>
  >     <dependency>
  >       <groupId>dep</groupId>
  >       <artifactId>two</artifactId>
  >     </dependency>
  >   </dependencies>
  > </project>
  > EOF

  $ ./pomdump.exe -j Test.java
  id: using:props-1.0
  deps:
    dep:one-2.0
    dep:two-2.1
  modules:
