################################################################################
#   QBuildSystem
#
#   Copyright(c) 2021 by Targoman Intelligent Processing <http://tip.co.ir>
#
#   Redistribution and use in source and binary forms are allowed under the
#   terms of BSD License 2.0.
################################################################################
!defined(BASE_PROJECT_PATH, var): error(BASE_PROJECT_PATH not set in .qmake.conf)
!defined(BASE_OUT_PATH, var): BASE_OUT_PATH=$$BASE_PROJECT_PATH/out
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
CONFIG(release){
    QMAKE_CXXFLAGS_RELEASE -= -O2
    QMAKE_CXXFLAGS_RELEASE += -O3
    BUILD_MODE=release
}
CONFIG(debug, debug|release){
   DEFINES += TARGOMAN_SHOW_DEBUG=1
   BUILD_MODE=debug
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


BaseLibraryFolder        = $$BASE_OUT_PATH/$$LibFolderPattern
BaseModulesFolder        = $$BASE_OUT_PATH/$$ModulesFolderPattern
BasePluginsFolder        = $$BASE_OUT_PATH/$$PluginsFolderPattern
BaseLibraryIncludeFolder = $$BASE_OUT_PATH/$$LibIncludeFolderPattern
BaseBinFolder            = $$BASE_OUT_PATH/$$BinFolderPattern
BaseTestBinFolder        = $$BASE_OUT_PATH/$$TestBinFolder
BaseUnitTestBinFolder    = $$BASE_OUT_PATH/$$UnitTestBinFolder
BaseBuildFolder          = $$BASE_OUT_PATH/$$BuildFolderPattern/$$ProjectName
BaseConfigFolder         = $$BASE_OUT_PATH/$$ConfigFolderPattern

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
                             $$BASE_OUT_PATH/lib64 \
                             $$BASE_OUT_PATH/lib \
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
message("* Base Out Path     : $$BASE_OUT_PATH")
message("* Install Path      : $$PREFIX/")
message("* Definitions       : $$DEFINES")
message("* DONT_BUILD_DEPS   : $$DONT_BUILD_DEPS")
message("* DISABLED_DEPS     : $$DISABLED_DPES")
message("* BuildMode         : $$BUILD_MODE")
message("******************************************************************** ")

!defined(CONFIG_TYPE, var) {
    unix: system($$QBUILD_PATH/scripts/buildDeps.sh $$BASE_PROJECT_PATH $$BASE_OUT_PATH/.depsBuilt $$BUILD_MODE $$DONT_BUILD_DEPS $$DISABLED_DPES)
    win32: error(submodule auto-compile has not yet been implemented for windows)
}
