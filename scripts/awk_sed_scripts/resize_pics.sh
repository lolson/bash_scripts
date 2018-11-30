#!/bin/bash
SRC=

ls > files
cat files | while read record;
do
    #echo "$record"
    MATCHED=`echo "$record" | grep '^[A-Za-z0-9]*.jpg'`
    if ["$MATCHED" != ""]; then
        break;
    fi 
#    echo "Matched $MATCHED"
    echo "$record"
    convert -resize 600x800 $MATCHED $MATCHED
done
rm files

