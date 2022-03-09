  $ ./xml.exe deps bom 1.3 <<EOF
  >   <dependencyManagement>
  >     <dependencies>
  >       <dependency>
  >         <groupId>deps</groupId>
  >         <artifactId>included</artifactId>
  >         <version>1.4</version>
  >       </dependency>
  >     </dependencies>
  >   </dependencyManagement>

  $ ./xml.exe project grampa 2.2 <<EOF
  >   <properties>
  >     <grampa.one>dunno</grampa.one>
  >     <grampa.two>maybe \${child.one}</grampa.two>
  >     <grampa.three>actually \${parent.two}</grampa.three>
  >     <grampa.classifier/>
  >   </properties>
  >   <dependencyManagement>
  >     <dependencies>
  >       <dependency>
  >         <groupId>deps</groupId>
  >         <artifactId>grampa</artifactId>
  >         <version>1.0</version>
  >         <exclusions>
  >           <exclusion>
  >             <groupId>deps</groupId>
  >             <artifactId>excluded</artifactId>
  >           </exclusion>
  >         </exclusions>
  >         <classifier>\${grampa.classifier}</classifier>
  >       </dependency>
  >       <dependency>
  >         <groupId>deps</groupId>
  >         <artifactId>over</artifactId>
  >         <version>1.0</version>
  >       </dependency>
  >       <dependency>
  >         <groupId>deps</groupId>
  >         <artifactId>atts</artifactId>
  >         <version>3.0</version>
  >       </dependency>
  >       <dependency>
  >         <groupId>deps</groupId>
  >         <artifactId>atts</artifactId>
  >         <version>3.0</version>
  >         <type>test-jar</type>
  >         <classifier>shared</classifier>
  >         <optional>true</optional>
  >       </dependency>
  >     </dependencies>
  >   </dependencyManagement>
  > EOF

  $ ./xml.exe project parent 1.0 <<EOF
  >   <parent>
  >     <groupId>project</groupId>
  >     <artifactId>grampa</artifactId>
  >     <version>2.2</version>
  >   </parent>
  >   <properties>
  >     <parent.one>no</parent.one>
  >     <parent.two>maybe \${child.one}</parent.two>
  >     <parent.three>actually \${parent.two}</parent.three>
  >   </properties>
  >   <dependencyManagement>
  >     <dependencies>
  >       <dependency>
  >         <groupId>deps</groupId>
  >         <artifactId>parent</artifactId>
  >         <version>1.0</version>
  >       </dependency>
  >       <dependency>
  >         <groupId>deps</groupId>
  >         <artifactId>over</artifactId>
  >         <version>1.1</version>
  >       </dependency>
  >     </dependencies>
  >   </dependencyManagement>
  > EOF

  $ cat > pom.xml <<EOF
  > <project>
  >   <parent>
  >     <groupId>project</groupId>
  >     <artifactId>parent</artifactId>
  >     <version>1.0</version>
  >   </parent>
  >   <artifactId>child</artifactId>
  >   <properties>
  >     <child.one>yes</child.one>
  >     <child.two>maybe \${child.one}</child.two>
  >     <child.three>\${project.version}</child.three>
  >     <child.four>\${something.invalid}</child.four>
  >     <dep.bom.ver>1.3</dep.bom.ver>
  >   </properties>
  >   <dependencyManagement>
  >     <dependencies>
  >       <dependency>
  >         <groupId>deps</groupId>
  >         <artifactId>child</artifactId>
  >         <version>1.0</version>
  >       </dependency>
  >       <dependency>
  >         <groupId>deps</groupId>
  >         <artifactId>over</artifactId>
  >         <version>1.2</version>
  >       </dependency>
  >       <dependency>
  >         <groupId>deps</groupId>
  >         <artifactId>bom</artifactId>
  >         <version>\${dep.bom.ver}</version>
  >         <scope>import</scope>
  >         <type>pom</type>
  >       </dependency>
  >     </dependencies>
  >   </dependencyManagement>
  > </project>

  $ ./efpom.exe src/main/java/Test.java
  id: project:child-1.0
  parent: project:parent-1.0
  properties:
    child.four: ${something.invalid}
    child.one: yes
    child.three: 1.0
    child.two: maybe yes
    dep.bom.ver: 1.3
    grampa.classifier: 
    grampa.one: dunno
    grampa.three: actually maybe yes
    grampa.two: maybe yes
    parent.one: no
    parent.three: actually maybe yes
    parent.two: maybe yes
    project.artifactId: child
    project.groupId: project
    project.version: 1.0
  depmgmt:
  - deps:atts-3.0
  - deps:atts-3.0
    classifier shared
    optional
    type test-jar
  - deps:child-1.0
  - deps:grampa-1.0
    excludes deps:excluded
  - deps:included-1.4
  - deps:over-1.2
  - deps:parent-1.0
