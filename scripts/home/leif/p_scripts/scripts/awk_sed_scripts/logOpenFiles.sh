#!/bin/bash
#####################################################################
#
# Purpose: script to log and monitor the number of files that a 
#          particular process has open. Run 
#          $ ulimit -n 
#          to show the OS default max number of open files that 
#          a process may have open.
#
# Author: lolson
#
#####################################################################

DATE=`date +%y%m%d`
TIME=`date +%H%M%S`
TM_PS=$1
LOG=/home/unityadm/logs/PID_$1_$DATE-$TIME.log
WAIT=5

while true; do
	STMT=`date +%H%M%S`", "`ls -l /proc/$TM_PS/fd | wc -l`
	echo $STMT >> $LOG
	echo $STMT
	sleep $WAIT
done
