#!/bin/bash
SRC=~/tmp/nio_stage/
ls "$SRC" > files
cat files | while read record;
do
    echo "$record"
    cat $SRC$record | sed 's/package java.nio;/package gov.bbg.nio;/' > $SRC/dist/$record
done
rm files
