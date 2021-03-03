#!/bin/bash
################################################################################
#   QBuildSystem
#
#   Copyright(c) 2021 by Targoman Intelligent Processing <http://tip.co.ir>
#
#   Redistribution and use in source and binary forms are allowed under the
#   terms of BSD License 2.0.
################################################################################
source `dirname ${BASH_SOURCE[0]}`/helper.shi

PROJECT_BASE_DIR=$1
DEPS_BUILT_FILE=$2
DONT_BUILD_DEPS=$3

if [ "$DONT_BUILD_DEPS" -eq 1 ]; then
    warn "Dependency build has been disabled"
    exit 0;
fi

cd $(realpath $PROJECT_BASE_DIR)
PROJECT_BASE_DIR=$(pwd)

if [ -f "$DEPS_BUILT_FILE" ]; then 
    if [ -f .gitmodules ]; then
        ignore "Submodules were built previously"
    fi
    exit 0
fi

CPU_COUNT=$(cat /proc/cpuinfo | grep processor | wc -l)
CPU_COUNT=$((CPU_COUNT-1))

QMAKE_CLI=qmake-qt5
if ! which $QMAKE_CLI >/dev/null 2>&1; then
    QMAKE_CLI=qmake
    if ! which $QMAKE_CLI >/dev/null 2>&1; then
        error "'qmake' command not found"
        exit 1
    fi
fi

if ! grep "Using Qt version 5." <<< $($QMAKE_CLI -v) >/dev/null 2>&1; then
    error "Qt version 5.x is needed for compiling."
    exit 1
fi

SubModulesBuildPath=$PROJECT_BASE_DIR/out/submodules
mkdir -p $SubModulesBuildPath

BaseQBuildSystemPath=`realpath $(dirname $0)/..`

DisabledDeps=''
for Disabled in ${@:4}; do
    DisabledDeps="$DisabledDeps $Disabled=0"
done


AllSubModules=()
AllSubModulesCommitDate=()

function lastCommitDate(){
    pushd $1 > /dev/null 2>&1
      echo $(git reflog show --pretty='%ct' | head -n 1)      
    popd  >/dev/null 2>&1
}

function buildModule() {
    local LevelTab=$2
    buildSubmodules $1 $2"\t"
    pushd $1 > /dev/null 2>&1
    info $LevelTab"Entering $1"
        if [ -r *".pro" ]; then
            make distclean
            $QMAKE_CLI PREFIX=$PROJECT_BASE_DIR/out \
                       DONT_BUILD_DEPS=1 \
                       BASE_OUT_PATH="$SubModulesBuildPath" \
                       QBUILD_PATH="$BaseQBuildSystemPath" \
                       $DisabledDeps
            make install -j $CPU_COUNT
            if [ $? -ne 0 ]; then 
                error $LevelTab"Error building as Qt project"; 
                exit 1; 
            fi
        elif [ -f "CMakeLists.txt" ];then
            PrjPath=$(pwd)
            buildPath=$SubModulesBuildPath/$(basename $1)/cmake
            mkdir -p $buildPath
            pushd $buildPath >/dev/null 2>&1
                cmake -DCMAKE_INSTALL_PREFIX:PATH=$PROJECT_BASE_DIR/out $PrjPath
                make install -j $CPU_COUNT
                if [ $? -ne 0 ]; then
                    error $LevelTab"Error building as a CMake project"
                    exit 1
                fi
            popd >/dev/null 2>&1
        else
            warn $LevelTab"Type could not be determined so will not be compiled"
        fi
    popd > /dev/null 2>&1
    info $LevelTab"Leaved $1"
}

function buildSubmodules() {
    local LevelTab=$2
    pushd $1 >/dev/null 2>&1
    info $LevelTab"Entered $1"
        if [ -f .gitmodules ]; then
            info "$LevelTab=====================> Submodules of $1 <========================"
            local SubModulePaths=($(git config --file .gitmodules  --get-regexp path | awk '{ print $2 }'))
            local SubModuleURLs=($(git config --file .gitmodules  --get-regexp url | awk '{ print $2 }'))
            
            for ((i=0;i<${#SubModuleURLs[@]}; ++i)); do
                Module=$(basename ${SubModuleURLs[i]})
                Module=${Module%".git"}
                ModulePath=${SubModulePaths[i]}
                if [ "QBuildSystem" = "$Module" ]; then  ignore $LevelTab"QBuildSystem module ignored"; continue; fi
                if [[ " ${@:4} " =~ " $Module " ]]; then ignore $LevelTab"Submodule $Module building ignored as specified"; continue; fi
                
                local IgnoreBuild=0
                if [[ " ${AllSubModules[@]} " =~ " ${Module} " ]]; then
                    commitDate=$(lastCommitDate $ModulePath)
                    if [ $commitDate -eq ${AllSubModulesCommitDate[$Module]} ]; then
                        ignore $LevelTab"same version ${Module} was built before"
                        continue
                    else 
                        if [ $commitDate -gt ${AllSubModulesCommitDate[$Module]} ];then
                            warn "Another submodule is dependent to older '${Module}'. What to do?"
                        else
                            warn "Another submodule is dependent to newer '${Module}'. What to do?"
                        fi
                        while [ 1 ];do 
                            warn "(I)gnore and use installed. (R)ebuild and overwrite. (B)reak and exit make process"
                            
                            case `read -n1 ans` in
                                'B' | 'b') exit 1 ;;
                                'I' | 'i') IgnoreBuild=1; break  ;;
                                'R' | 'r') break;;
                            esac
                        done
                    fi
                fi    
                
                if [ $IgnoreBuild -eq 0 ]; then
                    info $LevelTab"\n$LevelTab------------------------\n"$LevelTab"Building $Module on $1/$ModulePath"
                    buildModule $ModulePath $LevelTab
                    
                    AllSubModules+=($Module)
                    AllSubModulesCommitDate[$Module]=$(lastCommitDate $ModulePath)
                fi
            done
            
        fi
    popd  >/dev/null 2>&1
    info $LevelTab"Leaved $1"
}


buildSubmodules . 
date > $DEPS_BUILT_FILE

