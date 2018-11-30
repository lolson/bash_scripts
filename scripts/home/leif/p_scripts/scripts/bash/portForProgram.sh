#!/bin/bash
# Shows port used by a program
PID=`ps -elf | pgrep $1`
netstat -lntp | grep $PID
