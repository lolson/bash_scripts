#!/bin/bash
FILE=$1
PID=`ps -elf | grep jboss | grep java | awk '{print $4}'`
# reports RAM usage in K
ps -p $PID -O rss | awk '{print $2}' | tail -n 1 | awk '{mem = $1}; END {print "Memory usage =",mem/1024,"MB";};' > tmp 
jmap -heap $PID | tail -n 43 >> tmp
awk '{printf "%-50s\n", substr($0,1,50)}' tmp | sed 's/$/\|/g' > $FILE
rm tmp

# missing heap and non-heap 
#pmap $PID
#ps -C java -O rss | awk '{ count ++; sum += $2 }; END {count --; print "Number of processes =",count; print "Memory usage per process =",sum/1024/count, "MB"; print "Total memory usage =", sum/1024, "MB" ;};'
