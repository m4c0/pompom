  $ ./xml.exe project grampa 2.2 <<EOF
  >   <properties>
  >     <grampa.one>dunno</grampa.one>
  >     <grampa.two>maybe \${child.one}</grampa.two>
  >     <grampa.three>actually \${parent.two}</grampa.three>
  >   </properties>
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
  >   </properties>
  > </project>

  $ ./efpom.exe src/main/java/Test.java
  id: project:child-1.0
  parent: project:parent-1.0
  properties:
    child.four: ${something.invalid}
    child.one: yes
    child.three: 1.0
    child.two: maybe yes
    grampa.one: dunno
    grampa.three: actually maybe yes
    grampa.two: maybe yes
    parent.one: no
    parent.three: actually maybe yes
    parent.two: maybe yes
    project.artifactId: child
    project.groupId: project
    project.version: 1.0
