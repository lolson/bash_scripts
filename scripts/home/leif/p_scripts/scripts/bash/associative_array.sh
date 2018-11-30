#!/bin/bash

declare -A MAP
MAP[db-2]="i-fc5692d9"
MAP[esb-2]="i-ff5692da"
MAP[esb-1]="i-fe5692db"
MAP[db-1]="i-f95692dc"
MAP[admin-1]="i-b1519594"
MAP[puppet-1]="i-e95692cc"
MAP[mms-2]="i-e85692cd"
MAP[itos-1]="i-cc6bace9"

if [ "$#" -ne 1 ]; 
then
    echo "Incorrect number of parameters. Supply an instance alias name to start."
    echo "Valid COF instance aliases include:"
    for K in "${!MAP[@]}"; do echo $K; done
else
    echo "Using id ${MAP[$1]}"
    echo "For alias $1"
fi
