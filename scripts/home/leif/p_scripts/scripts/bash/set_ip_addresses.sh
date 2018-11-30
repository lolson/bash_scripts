#!/bin/bash
FILE=network.cfg
# overwrite config file if exists
echo ITOS=192.168.10.50 > $FILE
echo P1=192.168.10.51 >> $FILE
echo P2=192.168.10.53 >> $FILE
echo "> Done"
