#!/bin/bash
DATE=`date +%y%m%d`
TIME=`date +%H:%M:%S`
LOG=/home/leif/logs/uScript_$DATE-$TIME.log

CNT=1;
for((; CNT<=10; CNT++ )); do
    printf "#" >> $LOG;
    if [ $CNT == 5 ]; then
         printf " $TIME " >> $LOG;
    fi
    #echo $CNT
done
printf "\n" >> $LOG
