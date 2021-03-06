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
  >   <dependencies>
  >     <dependency>
  >       <groupId>deps</groupId>
  >       <artifactId>grampa</artifactId>
  >       <classifier>\${grampa.classifier}</classifier>
  >     </dependency>
  >   </dependencies>
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
  >   <dependencies>
  >     <dependency>
  >       <groupId>deps</groupId>
  >       <artifactId>parent</artifactId>
  >     </dependency>
  >   </dependencies>
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
  >         <scope>test</scope>
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
  >   <dependencies>
  >     <dependency>
  >       <groupId>deps</groupId>
  >       <artifactId>child</artifactId>
  >     </dependency>
  >     <dependency>
  >       <groupId>deps</groupId>
  >       <artifactId>over</artifactId>
  >     </dependency>
  >     <dependency>
  >       <groupId>deps</groupId>
  >       <artifactId>unrelated</artifactId>
  >       <version>9.2</version>
  >     </dependency>
  >   </dependencies>
  > </project>

  $ ./efpom.exe pom.xml
  id: project:child:1.0
  parent: project:parent:1.0
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
    project.parent.artifactId: parent
    project.parent.groupId: project
    project.parent.version: 1.0
    project.version: 1.0
  depmgmt:
  - deps:child:jar:1.0:compile
  - deps:over:jar:1.2:test
  - deps:parent:jar:1.0:compile
  - deps:grampa:jar:1.0:compile
    excludes deps:excluded
  - deps:atts:jar:3.0:compile
  - deps:atts:test-jar:3.0:compile
    classifier shared
    optional
  - deps:included:jar:1.4:compile
  dependencies:
  - deps:child:jar:1.0:compile
  - deps:over:jar:1.2:test
  - deps:unrelated:jar:9.2:compile
  - deps:parent:jar:1.0:compile
  - deps:grampa:jar:1.0:compile
    excludes deps:excluded
