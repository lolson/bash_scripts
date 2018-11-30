# XML properties
TIMESTAMP=$(date "+%Y-%m-%d_%H%M%S")
REPORT_NAME="ReadingsExport"
OUTPUT_FOLDER="/var/tmp/export/readings/"
LOG_FOLDER="$OUTPUT_FOLDER/logs"
BACKLOG="300"
NB_DEVICES_PER_FILE="10000"
CACHE_SIZE="1000"

XML="
  <taskManager user='Administrator'>
    <schedulerRequest>
    <jobName>$REPORT_NAME</jobName>
    <jobGroup>$REPORT_NAME</jobGroup>
    <urgent>false</urgent>
    <parameter>
      <property id='taskOrReportType'>$REPORT_NAME</property>
      <property id='executeNow'>true</property>
      <property id='jobGroup'>$REPORT_NAME</property>
      <property id='repeatPeriod'>00%3A05%3A00</property>
      <property id='report.remoteUser'>Administrator</property>
      <property id='repeatNbTime'>1</property>
      <property id='weeklyTime'>00%3A00</property>
      <property id='monthlyTime'>00%3A00</property>
      <property id='jobName'>$REPORT_NAME</property>
      <property id='hourlyTime'>00</property>
      <property id='monthlyDay'>01</property>
      <property id='taskOrReportName'>$REPORT_NAME</property>
      <property id='onceMonth'>01</property>
      <property id='dailyTime'>00%3A00</property>
      <property id='onceDay'>01</property>
      <property id='onceTime'>00%3A00</property>
      <property id='command.className'>com.trilliantnetworks.svc.quartzcommand.reports.ReportsCommand</property>
      <property id='backlog'>$BACKLOG</property>
      <property id='outputFilePath'>$OUTPUT_FOLDER</property>
      <property id='tempOutputFilePath'>$OUTPUT_FOLDER/tmp</property>
      <property id='logFilePath'>$LOG_FOLDER</property>
      <property id='nbDevicesPerFile'>$NB_DEVICES_PER_FILE</property>
      <property id='cacheSize'>$CACHE_SIZE</property>		
    </parameter>
    </schedulerRequest>
 </taskManager>"

 echo $XML >/dev/tcp/127.0.0.1/9997
