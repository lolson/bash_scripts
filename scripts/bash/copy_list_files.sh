#!/bin/bash
BASE=~/opt/git_repo/flightsoftware/cFEWorkspace

IFS=$'\n'
for j in `cat list.txt`

do 
#echo "$j"
#find $BASE -name "$j" -print
find $BASE -name "$j" | xargs -i cp "{}" ~/headers
done
