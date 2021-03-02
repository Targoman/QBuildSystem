################################################################################
#   QBuildSystem
#
#   Copyright(c) 2021 by Targoman Intelligent Processing <http://tip.co.ir>
#
#   Redistribution and use in source and binary forms are allowed under the
#   terms of BSD License 2.0.
################################################################################
CONFIG_TYPE="library"
include (./configs.pri)

TEMPLATE = lib
defined(LibName, var): TARGET = $$LibName
!defined(LibName, var): TARGET = $$ProjectName

QMAKE_CXXFLAGS_RELEASE += -fPIC
QMAKE_CXXFLAGS_DEBUG += -fPIC

equals(LIB_TYPE, static) {
    DEFINES += TARGOMAN_BUILD_STATIC
    CONFIG+=staticlib
} else {
    DEFINES += TARGOMAN_BUILD_SHARED
    LIB_TYPE  = shared
}

HEADERS += $$DIST_HEADERS \
           $$PRIVATE_HEADERS \
           $$SUBMODULE_HEADERS \

DESTDIR      = $$BaseLibraryFolder

include(./common.pri)

defined(LIB_PREFIX, var){
    unix: QMAKE_POST_LINK += $$QBUILD_PATH/qmake/linuxPostBuild.sh $$LIB_PREFIX $$BaseLibraryIncludeFolder $$BaseConfigFolder
    win32: error(post build for windows not implemented yet)
}else{
    unix: QMAKE_POST_LINK += $$QBUILD_PATH/qmake/linuxPostBuild.sh lib$$ProjectName $$BaseLibraryIncludeFolder $$BaseConfigFolder
    win32: error(post build for windows not implemented yet)
}

include(./install.pri)


 
