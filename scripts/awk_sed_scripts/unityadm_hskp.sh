#!/bin/ksh
#########################################################################
#									#
# Purpose: This is a housekeeping script				#
# Author: Paul Spencer 							#
# Creation Date: 28/12/10						#
#									#
# Version History:							#
# Who		When		What					#
# ---		----		----					#
# P.Spencer	29/12/10	Initial Version				#
#									#
#									#
#########################################################################

DATE=`date +%y%m%d`
ARC_DIR='/metering/ARCHIVE/UNITYADM'
ARC_LOAD_LOG='/metering/ARCHIVE/UNITYADM/LOAD_LOG'
LOG=$ARC_DIR/LOGS/unityadm_hskp_$DATE.log
DATALOAD='/var/unity-datauploader/archive'
DATALOAD2='/metering/archive'
LOAD_LOG='/opt/unity-datauploader/logs'
LOAD_LOG2='/metering/archive'
DATE_ARC=$ARC_DIR/$DATE
DATAUP_ARC=$DATE_ARC/unity-datauploader
TASKMAN='/opt/product/TrilliantNetworks/SerViewComTaskManager/bin'
TASKMAN_ARC=$DATE_ARC/taskmanager_logs

echo Starting Unityadm Housekeeping >>$LOG

echo "This was the diskspace before running the script" >>$LOG
echo "This was the diskspace before running the script"
df -k
df -k >>$LOG

#####################################################################
# Start of unitydatauploader block

# Check if the $DATE_ARC exists
if [ -d $DATE_ARC ]
	then
		echo "$DATE_ARC exists" >>$LOG
	else
		echo "Creating $DATE_ARC" >>$LOG
		mkdir $DATE_ARC
fi

# Check if the $DATAUP_ARC exists
if [ -d $DATAUP_ARC ]
	then
		echo "$DATAUP_ARC exists" >>$LOG
	else
		echo "Creating $DATAUP_ARC" >>$LOG
		mkdir $DATAUP_ARC
fi

# Move files older than 1 dayX into the $DATAUP_ARC
find $DATALOAD/* -mtime +1 -exec ls {} \; | while read FILE
do
mv $FILE $DATAUP_ARC
gzip $DATAUP_ARC/$FILE
echo "Moved file $FILE to $DATAUP_ARC" >>$LOG
done

find $DATALOAD2/*.dat -mtime +1 -exec ls {} \; | while read FILE
do
mv $FILE $DATAUP_ARC
gzip $DATAUP_ARC/$FILE
echo "Moved file $FILE to $DATAUP_ARC" >>$LOG
done

# Move files older than 1 day from the $LOAD_LOG into $ARC_LOAD_LOG
find $LOAD_LOG/* -mtime +1 -exec ls {} \; | while read FILE
do
mv $FILE* $ARC_LOAD_LOG
gzip $ARC_LOAD_LOG/$FILE*
echo "Moved file $FILE to $ARC_LOAD_LOG" >>$LOG
done

find $LOAD_LOG2/* -mtime +1 -exec ls {} \; | while read FILE
do
mv $FILE* $ARC_LOAD_LOG
gzip $ARC_LOAD_LOG/$FILE*
echo "Moved file $FILE to $ARC_LOAD_LOG" >>$LOG
done

# End of unitydatauploader blocks

#####################################################################

#####################################################################
# Start of Tasmanager log archive block

# Check if the $DATE_ARC exists
if [ -d $DATE_ARC ]
        then
                echo "$DATE_ARC exists" >>$LOG
        else
                echo "Creating $DATE_ARC" >>$LOG
                mkdir $DATE_ARC
fi

# Check if the $DATAUP_ARC exists
if [ -d $TASKMAN_ARC ]
        then
                echo "$TASKMAN_ARC exists" >>$LOG
        else
                echo "Creating $TASKMAN_ARC" >>$LOG
                mkdir $TASKMAN_ARC
fi

# Move files older than 1 dayX into the $DATAUP_ARC
find $TASKMAN/stdout.*20* -exec ls {} \; | while read FILE
do
gzip $FILE
mv $FILE* $TASKMAN_ARC
echo "Moved file $FILE to $TASKMAN_ARC" >>$LOG
done

# End of Tasmanager log archive block

#####################################################################
echo "This is the diskspace after running the script" >>$LOG
echo "This is the diskspace after running the script"
df -k
df -k >>$LOG


echo Finished Unityadm Housekeeping >>$LOG
