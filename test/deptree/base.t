  $ ../xml.exe deps child 1.0
  $ ../xml.exe deps transitive 2.0
  $ ../xml.exe deps unrelated 9.2
  $ ../xml.exe deps grampa 1.0 <<EOF
  > <dependencies>
  >   <dependency>
  >     <groupId>deps</groupId>
  >     <artifactId>transitive</artifactId>
  >     <version>2.0</version>
  >   </dependency>
  > </dependencies>

  $ ../xml.exe deps parent 1.0 <<EOF
  > <dependencies>
  >   <dependency>
  >     <groupId>deps</groupId>
  >     <artifactId>transitive</artifactId>
  >     <version>2.0</version>
  >   </dependency>
  > </dependencies>

  $ ../xml.exe deps bom 1.3 <<EOF
  >   <dependencyManagement>
  >     <dependencies>
  >       <dependency>
  >         <groupId>deps</groupId>
  >         <artifactId>included</artifactId>
  >         <version>1.4</version>
  >       </dependency>
  >     </dependencies>
  >   </dependencyManagement>

  $ ../xml.exe deps over 1.2 <<EOF
  > <dependencyManagement>
  >   <dependencies>
  >     <dependency>
  >       <groupId>deps</groupId>
  >       <artifactId>weird-test-dep</artifactId>
  >       <version>6.9</version>
  >       <scope>test</scope>
  >     </dependency>
  >   </dependencies>
  > </dependencyManagement>
  > <dependencies>
  >   <dependency>
  >     <groupId>deps</groupId>
  >     <artifactId>transitive</artifactId>
  >     <version>2.0</version>
  >   </dependency>
  >   <dependency>
  >     <groupId>deps</groupId>
  >     <artifactId>weird-test-dep</artifactId>
  >   </dependency>
  > </dependencies>

  $ ../xml.exe project grampa 2.2 <<EOF
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

  $ ../xml.exe project parent 1.0 <<EOF
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
  >       <scope>test</scope>
  >     </dependency>
  >     <dependency>
  >       <groupId>deps</groupId>
  >       <artifactId>unrelated</artifactId>
  >       <version>9.2</version>
  >     </dependency>
  >   </dependencies>
  > </project>

  $ ../deptree.exe pom.xml
  project:child:jar:1.0
    deps:child:jar:1.0:compile
    deps:over:jar:1.2:test
      deps:transitive:jar:2.0:test
    deps:unrelated:jar:9.2:compile
    deps:parent:jar:1.0:compile
    deps:grampa:jar:1.0:compile
