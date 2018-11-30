#!/bin/bash
#Redirect a folder list of files to "files"
#Read each line in this list of file names which all share the 
#same prefix and rename them with the prefix removed
#this was used as a helper script to convert a batch of jpg 
#files into a single pdf
#   $> convert *.jpg consolidated.pdf
SRC="Moving Claims Report"

ls "$SRC" > files
cat files | while read record;
do
    echo "$record"
    NEW_FILE_NAME=`echo "$record" | sed 's/claims_report_scan-//g'`
    echo "New name $NEW_FILE_NAME"
    mv "$SRC/$record" "$SRC/$NEW_FILE_NAME"
done
rm files

# now that these files have their prefix removed
# still need to order them lexigraphically
# unfortunately $> ls | sort -n | convert out.pdf
# does not work.  The problem is two digit numbered file names
# appearing before single digit in out of ls
# by appending 'a' as a prefix to the two digit file names,
# we get the desired ordering used by 'convert'
ls "$SRC" > files
cat files | while read record;
do
    #echo "$record"
    MATCHED=`echo "$record" | grep '^[0-9][0-9].jpg'`
    if ["$MATCHED" != ""]; then
        break;
    fi 
#    echo "Matched $MATCHED"
    echo "$record"
    mv "$SRC/$MATCHED" "$SRC/a$MATCHED"
done
rm files

