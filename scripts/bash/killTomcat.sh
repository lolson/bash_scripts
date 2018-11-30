#!/bin/bash
TOMCAT_PS=`ps -ef | grep tomcat | grep ClassLoader | awk '{print $2}'`
kill -9 $TOMCAT_PS
