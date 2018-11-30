#!/bin/bash
# Script an svn commit of a changelist mycl  eg
# @arg the commit detail message
# svn commit -m --changelist mycl -m "[#1234] Fixing it"
#if [ "$1" == help ]; then
if [[ "$1" == help || "$1" == "-help" ]]; then
    echo "usage > svncmt \"[#1234] Fixing it\""
    echo svn cl mycl scr/pojo1.java src/pojo2.java
    echo svn commit --changelist mycl -m \"[#1234] Fixing it\"
else
#echo \"$1\"
    svn commit --changelist mycl -m "$1"
fi

