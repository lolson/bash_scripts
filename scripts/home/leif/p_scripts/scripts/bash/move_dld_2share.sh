#!/bin/bash
MIN=5
SRC=~/Downloads
DEST=~/Documents/dropbox_share
# find file in downloads with modified by date < 5 mins
#for `find ~/Downloads -mmin -5 -print`
# loop over files, as it handles spaces and newlines in file names
find $SRC -mmin -$MIN -type f -print0 | while IFS= read -r -d $'\0' line; do
    echo "$line"
    cp "$line" $DEST
done
