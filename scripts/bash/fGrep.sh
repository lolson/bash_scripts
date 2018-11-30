#!/bin/bash
# find . -name 'someFileType' | xargs grep 'somePattern'

if [[ "$1" == help || "$1" == "-help" ]]; then 
    echo "Usage: takes two arguments, first a file name or pattern, second a pattern to grep for" 
    echo "For best results double quote each argument"
    echo "fGrep \"someFile\" \"somePattern\""
    echo "Executes: find . -name \"someFile\" | xargs grep \"somePattern\""
else
    find . -name "$1" | xargs grep "$2"
    # find . -name $1 | xargs grep $2
fi
