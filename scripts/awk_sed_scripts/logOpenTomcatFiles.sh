#!/bin/bash
#####################################################################
#
# Purpose: script to log number of files open by Tomcat process
#
# Author: lolson
#
#####################################################################

DATE=`date +%y%m%d`
TIME=`date +%H%M%S`
START=000900
LOG=/home/tomcat/logs/tomcat_open_files_$DATE-$TIME.log
JPID=`ps aux | grep java | grep bin | awk '{print $2}'`
FILE_CNT=`ls -l /proc/$JPID/fd | wc -l`

SZ=87
WAIT=30
while true; do
        TIME=`date +%H%M%S`
        if [ "$TIME" -gt "$START" ]; then
                break
        fi
        sleep $WAIT
done

while true; do
        TIME=`date '+%Y-%m-%d %H:%M:%S'`
        echo $TIME - $FILE_CNT >> $LOG
        sleep $WAIT
done

