#!/bin/bash
TOMEE_PS=`ps -f | grep apache-tomee | grep ClassLoader | awk '{print $2}'`
kill -9 $TOMEE_PS
