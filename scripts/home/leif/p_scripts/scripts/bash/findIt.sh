#!/bin/bash
if [[ "$1" == help || "$1" == "-help" ]]; then 
    echo "Usage: takes one argument a file name" 
    echo "For best results double quote the file name"
    echo "findIt \"someFile\""
    echo "Executes: find . -name \"someFile\" -print"
else
    find . -name $1 -print
fi
