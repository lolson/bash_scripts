#!/bin/bash
export PATH=/home/unityadm/opt/jdk1.6.0_26/bin:$PATH
#Run missing reads report every 24 hr (86400 sec) 
#less 2 min (120 sec) it takes for report to run 
# 86400 - 120 = 86280 sec
sleep 72000
while true; do
   ./runner.sh CSV MISSING_READS_REPORT
   ./mail_report.sh
   sleep 86280
done
