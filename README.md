[ ![Codeship Status for cui-liqiang/simple-make](https://www.codeship.io/projects/f1ed2cf0-26e9-0132-d20a-1e2244bd06ff/status)](https://www.codeship.io/projects/37580)
## Installation
gem install simple-make

## Usage
 - Create a file named build.sm
 - Do some configuration changes in build.sm
 - Run command "sm", then Makefile should be created

## Recommended Project Folder Structure
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
Add configurations in build.sm.
### Madatory
**None** if you follow the folder structure described above
### Basic
#####Project Name
e.g. ```name="sample-name"```. **Default value**: name of the folder where "sm" runs
#####Dependencies
A static libaray dependency. List the following to describe this dependency:
 - Search path of the headers for this lib
 - Static lib file path with form: "/path/to/lib/libxxx.a"
 - Scope, which could be compile/test/prod. "compile" is the **default value** if not given. Meanings of scope are listed in the latter section.
Search path and lib file path can be absolute or relative to the folder where "sm" runs
 - Examples:

 	```
 		depend_on({include:"includes", lib:"libs/libgtest_main.a", scope: :test})
 	```
 	```
 		depend_on({include:"includes1", lib:"libs/libmockcpp.a", scope: :test},
 				  {include:"includes2", lib:"libs/libgtestcpp.a", scope: :test})
 	```

#####Search Path
Similiar to **Dependencies**, but only search path needed.

```
header_search_path({path:"/search/path", scope::compile})
```

## Scope
**scope** is an attribute for both **Dependencies** and **Search Path**. Value of **scope** could be compile/test/prod

 - compile. 
If a **Dependencies** or **Search Path** is used by code within **app** folder described in **Recommended Project Folder Structure** section, use compile as the scope value.
 - test. 
Similiar with **compile**, except it's related to **test** folder described in **Recommended Project Folder Structure** section.
 - prod. 
Similiar with **compile**, except it's related to **prod** folder described in **Recommended Project Folder Structure** section.

## Sample Project
**sample-project** is an example to demo how simple-make work. **sample-libs** is the gtest library. Check sample-project/build.sm to see how it is confingured.
Run "sm" within sample-project folder, and Makefile will be generated. Currently there are only two make targets supported: "test", "run".

**Notice**: the sample-libs/libs/libgtest_main.a is compiled on Mac. If your platform is not Mac, you should recompile the libgtest_main.a from source and replace this one.
