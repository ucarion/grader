# About

## What operating system are submissions tested on?

Submissions are placed in a virtual machine running Ubuntu 12.04 LTS (Precise
Pangolin). We're open to adding new operating systems to test on, but we can
only use open-source OSes at the moment.

## What programming languages are supported?

Languages currently offerred are:

* Java
* C
* C++
* Python
* Ruby

If the programming language you're using isn't listed here but can be installed
or compiled on Ubuntu, it can easily be added, just ask.

### What versions of those languages are you using?

#### Java

We're using Java 1.7 for both the runtime and compiler.

```
$ java -version
java version "1.7.0_51"
Java(TM) SE Runtime Environment (build 1.7.0_51-b13)
Java HotSpot(TM) 64-Bit Server VM (build 24.51-b03, mixed mode)

$ javac -version
javac 1.7.0_51
```

#### C

C programing are compiled with GCC using version 4.6.3.

```
$ gcc --version
gcc (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3
```

#### C++

We compile C++ programs with G++ version 4.6.3.

```
$ g++ --version
g++ (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3
```

#### Python

We've chosen to stick with Python 2.7.3 for testing submissions. We're planning
on adding support for Python 3 as well soon.

```
$ python --version
Python 2.7.3
```

#### Ruby

Submissions written in Ruby are tested using MRI (CRuby) version 1.9.3.

```
$ ruby --version
ruby 1.9.3p0 (2011-10-30 revision 33570) [x86_64-linux]
```
