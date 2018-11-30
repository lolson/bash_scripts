#!/bin/bash

EMAIL_TO=""
REPORT_FULL_NAME="Financial Reads Export"
REPORT_SHORT_NAME="financials"
END_OF_FILE_TAG="</FinancialReads>"
OUTPUT_FOLDER="/var/tmp/export/financials" # no trailing slash 
ZIP_PWD="12345"

# FTP properties
FTP_HOST="192.168.200.20"
FTP_USER="balday"
FTP_PASSWD='Ar\$143ba' # warning: you have to escape this string to be used by expect package
IS_SFTP=true

CURRENT=`date +%Y%m%d`
EXPORTED_FILES=""
PROCESS_START_DATE="Not started"


# Sends an email when there is an error.
# It will exit the current process with an error code of 1.
# First paramater is the error message.  
# The other parameters are files paths for which file content should be appended to the email.
sendErrorMail() {
  local ERROR_MSG=$1
  local CURRENT=`date`

  [ -z $EXPORTED_FILES ] && EXPORTED_FILES="None"

  ERROR_MAIL="
    $REPORT_FULL_NAME\n\n
    Process has been running since: $PROCESS_START_DATE\n
    Current time: $CURRENT\n\n

    An error occured:\n
    $ERROR_MSG\n\n

    List of files that have successfully be exported and must be processed:\n
    $EXPORTED_FILES\n
  "
 
  shift # shift to second parameter

  for log in "$@";
  do
    ERROR_MAIL="$ERROR_MAIL\n
      $log\n
      =====================================================================\n      
    "    
    LOG_CONTENT=`sed 's/\$/\\\\n/g' $log` # add \n at the end of lines so 'echo -e' can display correctly
    ERROR_MAIL=$ERROR_MAIL"\n$LOG_CONTENT\n"
  done;
 
  echo $ERROR_MSG
  echo -e $ERROR_MAIL | mail -s "$REPORT_FULL_NAME - Error" $EMAIL_TO 
  exit 1
}


# Waits that a file has been completely written.
# When the content of END_OF_FILE_TAG is found in a file, 
# it indicates that file has been completely written.
# The only parameter is the path of the file to watch.
waitForEndOfFile() {
  local filename=$1
  local retry=0
  echo "Waiting for the completion of writing $filename ..."

  while [ true ];
  do
    [ -f $filename ] && [ `grep -c $END_OF_FILE_TAG $filename` -ge 1 ] && break

    if [ $retry -ge 1800 ] # if it's been more than 1 hour ...
    then
      sendErrorMail "Could not detect the completion of the file $filename in an hour." $METADATA_FILE
    fi

    sleep 2
    ((retry++))
  done
}


# Transfers a file on a FTP server.
# The settings of the FTP are specified by the variables 
# FTP_HOST, FTP_USER and FTP_PASSWD.
# The only parameter is the path of the file to transfer.
transferFileToFTP() {
  local FILENAME=$1
  local FTP_LOG_TIMESTAMP=`date +%Y%m%d_%H%M%S`
  local FTP_LOG="$OUTPUT_FOLDER/$REPORT_SHORT_NAME-$FTP_LOG_TIMESTAMP.ftp.log"

if [ $IS_SFTP == "true" ]
  then
  echo "Transfering $FILENAME to SFTP ..."
EXEC=$(expect -c "spawn /usr/bin/sftp -o \"BatchMode no\" $FTP_USER@$FTP_HOST
expect \"password:\"
send \"$FTP_PASSWD\r\"
expect \"sftp>\"
send \"put $FILENAME\r\"
expect \"Uploading $FILENAME\"
expect \"$FILENAME\"
expect \"sftp>\"
send \"quit\r\"
")

echo "$EXEC" << END_SCRIPT > $FTP_LOG
put $FILENAME
quit
END_SCRIPT
FTP_SUCCESS_MSG="100%" 
  else  
    echo "Transfering $FILENAME to FTP ..." 
    ftp -inv $FTP_HOST <<END_SCRIPT > $FTP_LOG
    quote USER $FTP_USER
    quote PASS $FTP_PASSWD
    bin
    put $FILENAME
    quit
END_SCRIPT

  FTP_SUCCESS_MSG="226 Transfer complete"
fi
  if [ `fgrep "$FTP_SUCCESS_MSG" $FTP_LOG -c` -eq 0 ] ;then
    sendErrorMail "Could not transfer the file $FILENAME on the FTP." $FTP_LOG $METADATA_FILEa
  else
    echo "Transfer complete."
  fi

}

processFiles() {

    exportFilename=`ls -t $REPORT_SHORT_NAME-$CURRENT*.$fileNb.xml 2>/dev/null | head -n 1`	
	if [ -f "$exportFilename" ]
	then
	if [ $fileNb -eq 1 ]
	  then	  
	    # SEND START PROCESS MAIL
		PROCESS_START_DATE=`date`

		START_MAIL="
		$REPORT_FULL_NAME\n\n
		Process has started at: $PROCESS_START_DATE\n
		"
          echo -e $START_MAIL | mail -s "$REPORT_FULL_NAME - Start of process" $EMAIL_TO
	  fi
	  
	  exportFileId=`echo $exportFilename |  cut -d'-' -f 3 | cut -d'.' -f 1`
	fi  
	
	while [ -f "$exportFilename" ]
	do	            
          zipfile="$exportFilename.zip"
          waitForEndOfFile $exportFilename
          zip -q -P $ZIP_PWD $zipfile $exportFilename
          transferFileToFTP $zipfile
          EXPORTED_FILES="$EXPORTED_FILES$exportFilename\n" 	
          retry=0 #reset the timeout
	  
          ((fileNb++))
          exportFilename=`ls -t $REPORT_SHORT_NAME-$CURRENT-$exportFileId.$fileNb.xml 2>/dev/null | head -n 1` 	
        done
}

cd $OUTPUT_FOLDER
retry=0
fileNb=1
METADATA_FILE=`find $OUTPUT_FOLDER -type f -name "$REPORT_SHORT_NAME-$CURRENT*metadata.xml" | tail -n 1`

# wait for metadata file
while [ ! -f "$METADATA_FILE" ];
do
active=$(($retry % 60))

  if [ $active -eq 0 ]
  then
    if [ $retry -ne 0 ] 
    then
    echo  Waiting for new files ...	
    fi
  fi

  processFiles	   
  
  if [ $retry -ge 1200 ] # if it's been more than 1 hour ...
  then
    sendErrorMail "No export file has been written during the last hour and the metadata file is not found."
  fi

  sleep 5 # wait 5 seconds and retry
  ((retry++))

  METADATA_FILE=`find $OUTPUT_FOLDER -type f -name "$REPORT_SHORT_NAME-$CURRENT*metadata.xml" | tail -n 1`
done
echo "Metadata file: $METADATA_FILE"

# verify if there're still some files to process after the metadata file has been written
 processFiles

# SEND END OF PROCESS MAIL
PROCESS_END_DATE=`date`

END_MAIL="
  $START_MAIL
  Process has finished at: $PROCESS_END_DATE\n\n

  List of files to process:\n
  $EXPORTED_FILES\n\n

  Metadata file:\n
"
(echo -e $END_MAIL; cat $METADATA_FILE;) | mail -s "$REPORT_FULL_NAME - End of process" $EMAIL_TO

echo "Export completed!"
