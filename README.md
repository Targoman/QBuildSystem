# QBuildSystem
qmake include files and bash scripts in order to build complex projects easy to handle

### Table of contents
- [Motivation](#motivation)
- [Sample codes](#sample-codes)
- [Features](#features)
- [Setup](#setup)
- [License](#license)


# Motivation
[TOC](#table-of-contents)
Building large projects with external dependencies is complex. Qt has its build system and supports both qmake and cmake, but none are easy to be used with complex projects with multiple subprojects and external project dependencies. In order to ease the process of creating these projects, you can find all over the Targoman repository we have made some qmake `pri` files and shell scripts. 

# Sample projects
[TOC](#table-of-contents)
Sample projects can be found in [QBuildSystem-sampleLibrary](https://github.com/Targoman/QBuildSystem-sampleLibrary) and [QBuildSystem-sampleApp](https://github.com/Targoman/QBuildSystem-sampleApp) repositories.


# Features
[TOC](#table-of-contents)
* supports subprojects
* auto build of dependencies based on git submodules
* library linking
* versioning support
* multiple templates for 
	* application
	* libraries (static/dynamic)
	* tests
	* unittest
	* examples
* installation
* configuration export

# Setup
[TOC](#table-of-contents)
1. Add QBuildSystem as your project submodule 
```
$ git submodule add https://github.com/Targoman/QBuildSystem.git 3rdParty/QBuildSystem
```
2. Create a file named `.qmake.conf` at top folder of your project
```
$ cat <<EOF > .qmake.conf 
BASE_PROJECT_PATH=\$\$PWD
QBUILD_PATH=\$\$BASE_PROJECT_PATH/3rdParty/QBuildSystem/
EOF
```
Follow guides on sample projects to create your project

# License
[TOC](#table-of-contents)

QBuildSystem has been published under the terms of [Modified BSD License](./LICENSE) 
