#!/bin/bash
# Take timestamped snapshots of the top command
# pass in PID as arg
TS=`date +%Y-%m-%d`
LOG=top_$TS.log
#top -p "$@" >> $LOG
while true;
do
   date +%Y-%m-%d:%H:%M >> $LOG ;
   top -b -n 1 -p "$@" >> $LOG;
   sleep 5m;
done

