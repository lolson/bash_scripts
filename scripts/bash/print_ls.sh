#!/bin/bash

ls -lrt /etc > file
echo "" >> file
#cat file
IFS=$'\n'
for next in `cat $file`
do
    echo "$next read from $file" 
done
exit 0
