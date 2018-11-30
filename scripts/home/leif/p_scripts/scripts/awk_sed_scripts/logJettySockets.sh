#!/bin/bash
#####################################################################
#
# Purpose: script to log Jetty sockets status
#
# Author: lolson
#
#####################################################################

DATE=`date +%y%m%d`
TIME=`date +%H%M%S`
START=234500
LOG=/metering/tmplog/JettySocket_$DATE-$TIME.log
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
	for ((c=1; c<=$SZ; c++)); do
		printf '-' >> $LOG
	done
	printf '\n' >> $LOG
        TIME=`date +%H:%M:%S`
	echo $TIME >> $LOG
        netstat -an | grep 3003 >> $LOG
        sleep $WAIT
done

