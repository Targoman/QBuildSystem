################################################################################
#   QBuildSystem
#
#   Copyright(c) 2021 by Targoman Intelligent Processing <http://tip.co.ir>
#
#   Redistribution and use in source and binary forms are allowed under the
#   terms of BSD License 2.0.
################################################################################
include (../base/base.pri)

!defined(APP_NAME, var): APP_NAME=$$ProjectName

TEMPLATE = app
TARGET=$$APP_NAME

DESTDIR      = $$BaseBinFolder

include(../base/common.pri)
