################################################################################
#   QBuildSystem
#
#   Copyright(c) 2021 by Targoman Intelligent Processing <http://tip.co.ir>
#
#   Redistribution and use in source and binary forms are allowed under the
#   terms of BSD License 2.0.
################################################################################
include (../base/base.pri)

TEMPLATE = lib
CONFIG += plugin

QMAKE_CXXFLAGS_RELEASE += -fPIC
QMAKE_CXXFLAGS_DEBUG += -fPIC

equals(MODULE_TYPE, static) {
    DEFINES += TARGOMAN_BUILD_STATIC
    CONFIG+=staticlib
} else {
    DEFINES += TARGOMAN_BUILD_SHARED
    LIB_TYPE  = shared
}

HEADERS += $$DIST_HEADERS \
           $$PRIVATE_HEADERS \
           $$SUBMODULE_HEADERS \

equals(CONFIG_TYPE, module): DESTDIR  = $$BaseModulesFolder
equals(CONFIG_TYPE, plugin): DESTDIR  = $$BasePluginsFolder

include(./common.pri)



 
