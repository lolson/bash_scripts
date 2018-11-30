#!/bin/bash
TS=`date +%Y-%m-%d`
QUERY=\'"{\"q\": [{\"field\": \"timestamp\", \"op\": \"ge\", \"value\": \"$TS\"}]}"\'

echo "-d" $QUERY
