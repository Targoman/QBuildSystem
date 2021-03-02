################################################################################
#   QBuildSystem
#
#   Copyright(c) 2021 by Targoman Intelligent Processing <http://tip.co.ir>
#
#   Redistribution and use in source and binary forms are allowed under the
#   terms of BSD License 2.0.
################################################################################
!defined(BASE_PROJECT_PATH, var): error(BASE_PROJECT_PATH not set in .qmake.conf)
!defined(VERSION, var){
    VersionFile=$$BASE_PROJECT_PATH/version.pri
    !exists($$VersionFile): error("**** Unable to find version info file $$VersionFile ****")
    include ($$VersionFile)
}

!defined(ProjectName, var): error(ProjectName not specified in version file)
!defined(VERSION, var): error(variable VERSION not set in version file)
!defined(PREFIX, var): PREFIX=~/local
!defined(DONT_BUILD_DEPS, var): DONT_BUILD_DEPS=0

#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-++-+-+-
CONFIG(debug, debug|release): DEFINES += TARGOMAN_SHOW_DEBUG=1
CONFIG(release){
    QMAKE_CXXFLAGS_RELEASE -= -O2
    QMAKE_CXXFLAGS_RELEASE += -O3
}

DEFINES += PROJ_VERSION=$$VERSION

#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-++-+-
contains(QT_ARCH, x86_64){
    LibFolderPattern     = lib64
} else {
    LibFolderPattern     = lib
}
ModulesFolderPattern    = modules
PluginsFolderPattern    = plugins
LibIncludeFolderPattern = include
BinFolderPattern        = bin
BuildFolderPattern      = build
TestBinFolder           = test
UnitTestBinFolder       = unitTest
ConfigFolderPattern     = conf


BaseLibraryFolder        = $$BASE_PROJECT_PATH/out/$$LibFolderPattern
BaseModulesFolder        = $$BASE_PROJECT_PATH/out/$$ModulesFolderPattern
BasePluginsFolder        = $$BASE_PROJECT_PATH/out/$$PluginsFolderPattern
BaseLibraryIncludeFolder = $$BASE_PROJECT_PATH/out/$$LibIncludeFolderPattern
BaseBinFolder            = $$BASE_PROJECT_PATH/out/$$BinFolderPattern
BaseTestBinFolder        = $$BASE_PROJECT_PATH/out/$$TestBinFolder
BaseUnitTestBinFolder    = $$BASE_PROJECT_PATH/out/$$UnitTestBinFolder
BaseBuildFolder          = $$BASE_PROJECT_PATH/out/$$BuildFolderPattern/$$ProjectName
BaseConfigFolder         = $$BASE_PROJECT_PATH/out/$$ConfigFolderPattern

#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-++-+-
INCLUDEPATH += $$BASE_PROJECT_PATH \
               $$BASE_PROJECT_PATH/src \
               $$BASE_PROJECT_PATH/libsrc \
               $$BaseLibraryIncludeFolder \
               $$PREFIX/include \
               $(HOME)/local/include \
               $$DependencyIncludePaths/

#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-++-+-
DependencyLibPaths      +=   $$BaseLibraryFolder \
                             $$BASE_PROJECT_PATH/out/lib64 \
                             $$BASE_PROJECT_PATH/out/lib \
                             $$PREFIX/lib64 \
                             $$PREFIX/lib \
                             $(HOME)/local/lib \
                             $(HOME)/local/lib64 \

#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-++-+-+-
win32: DEFINES += _WINDOWS
FullDependencySearchPaths = $$DependencyLibPaths
unix:
  FullDependencySearchPaths+=  /usr/lib \
                               /usr/lib64 \
                               /usr/local/lib \
                               /usr/local/lib64 \
                               /lib/x86_64-linux-gnu


QMAKE_LIBDIR += $$FullDependencySearchPaths

#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-++-+-
defineTest(addSubdirs) {
    for(subdirs, 1) {
        entries = $$files($$subdirs)
        for(entry, entries) {
            name = $$replace(entry, [/\\\\], _)
            SUBDIRS += $$name
            eval ($${name}.subdir = $$entry)
            for(dep, 2):eval ($${name}.depends += $$replace(dep, [/\\\\], _))
            export ($${name}.subdir)
            export ($${name}.depends)
        }
    }
    export (SUBDIRS)
}

#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-++-+-+-
message("*******************   $$ProjectName BASE CONFIG  ************************ ")
message("* Building $$ProjectName Ver. $$VERSION")
message("* Base Project Path : $$BASE_PROJECT_PATH")
message("* Install Path      : $$PREFIX/")
message("* Definitions       : $$DEFINES")
message("* DONT_BUILD_DEPS   : $$DONT_BUILD_DEPS")
message("* DISABLED_DEPS     : $$DISABLED_DPES")
message("******************************************************************** ")

!defined(CONFIG_TYPE, var) {
    unix: system($$QBUILD_PATH/qmake/buildDeps.sh $$BASE_PROJECT_PATH $$BASE_PROJECT_PATH/out/.depsBuilt $$DONT_BUILD_DEPS $$DISABLED_DPES)
    win32: error(submodule auto-compile has not yet been implemented for windows)
}
