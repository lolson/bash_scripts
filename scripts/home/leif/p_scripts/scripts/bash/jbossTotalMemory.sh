#!/bin/bash
PID=`ps -elf | grep jboss | grep java | awk '{print $4}'`
# reports RAM usage in K
#ps -p $PID -O size
ps -p $PID -O rss | awk '{print $2}' | tail -n 1 | awk '{mem = $1}; END {print "Memory usage =",mem/1024,"MB";};'
jmap -heap $PID
# missing heap and non-heap 
#pmap $PID
#ps -C java -O rss | awk '{ count ++; sum += $2 }; END {count --; print "Number of processes =",count; print "Memory usage per process =",sum/1024/count, "MB"; print "Total memory usage =", sum/1024, "MB" ;};'
