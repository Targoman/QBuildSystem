################################################################################
#   QBuildSystem
#
#   Copyright(c) 2021 by Targoman Intelligent Processing <http://tip.co.ir>
#
#   Redistribution and use in source and binary forms are allowed under the
#   terms of BSD License 2.0.
################################################################################
CONFIG_TYPE="plugin"
!defined(BASE_PROJECT_PATH, var): error(BASE_PROJECT_PATH not set in .qmake.conf)
!defined(VERSION, var){
    VersionFile=$$BASE_PROJECT_PATH/version.pri
    !exists($$VersionFile): error("**** Unable to find version info file $$VersionFile ****")
    include ($$VersionFile)
}
defined(PluginName): TARGET = $$PluginName
!defined(PluginName): TARGET = $$ProjectName
include (../base/plugin-base.pri)
