## Installation
gem install simple-make

## Usage
 - Create a file named build.sm
 - Do some configuration changes in build.sm
 - Run command "sm", then Makefile should be created

## Typical Project Folder Structure
```
$ tree
.
├── app
│   ├── include
│   │   ├── domain
│   │   │   └── User.h
│   │   ├── service
│   │   └── util
│   └── src
│       ├── domain
│       │   └── User.cc
│       ├── service
│       └── util
├── build.sm
├── prod
│   ├── include
│   └── src
│       └── Main.cc
└── test
    ├── include
    └── src
        └── domain
            └── UserTest.cc
```
 - **app**: Most of your source files should be here. Within "app" folder, there are "include" and "src". "app/include" is added to search path automatically, and all files within "app/src" will be compiled
 - **build.sm**: the build file
 - **prod**: Similiar with **app** folder. The source files **needed and only needed** when producing production executable
 - **test**: Similiar with **app** folder. The source files **needed and only needed** when producing unit test executable

## Configuration
One configuration item per line
### Madatory
**None** if you follow the folder structure described above
### Basic
 - **Project Name**. e.g. name="sample-name". **Default value**: name of the folder where you run the command
 - **Dependencies**. A static libaray dependency. List the following to describe this dependency:
    - Search path of the headers for this lib
    - Static lib file path with form "/path/to/lib/libxxx.a"
    - Scope, which could be compile/test/prod. "compile" is the **default value** if not given. Meanings of scope are listed in the later section
 	- Search path and lib file path can be absolute or relative to the folder where "sm" runs
 	- Example(for one and for multiple):

 	```
 		depend_on({include:"includes", lib:"libs/libgtest_main.a", scope: :test})
 	```
 	```
 		depend_on({include:"includes1", lib:"libs/libmockcpp.a", scope: :test},
 				  {include:"includes2", lib:"libs/libgtestcpp.a", scope: :test})
 	```
 - **Search Path**. Similiar to **Dependencies**, but only search path needed.

 	```
 		header_search_path({path:"/search/path", scope::compile})
 	```