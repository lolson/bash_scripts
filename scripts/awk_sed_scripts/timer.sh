#!/bin/ksh
while true  do
    # get the current hour
    HOUR=`date ""+%H`
    MIN=`date ""+%M`

    echo ""Hour is $HOUR and minute is $MIN""

    if [ $HOUR != 23 ]; then
        echo ""Time not reached - sleeping...""
        sleep 15
    else
        echo ""Run the script""
    #   ./runner.sh CSV MISSING_READS_REPORT
    #   ./mail_report.sh
        sleep 3600
    fi
done
exit 0

