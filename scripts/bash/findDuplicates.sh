#!/bin/bash
# Finds any duplicate files found under two directories 'main' and 'index'
ROOT=/home/leif/.bbg/managed_sites/voanews
cd $ROOT
find main -type f | sed 's/^main//g' > main.txt
find index -type f | sed 's/^index//g' > index.txt

cat main.txt | sort > file1
cat index.txt | sort > file2
comm -12 file1 file2 
rm main.txt index.txt file1 file2
