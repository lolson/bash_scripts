#!/bin/bash
LIB_ROOT=/opt/apache-tomee-plus-1.5.1
LIB_ROOT_WEB=/opt/apache-tomee-plus-1.5.1/webapps/ROOT/WEB-INF/lib
#TOMCAT_EXT=$TOMCAT_ROOT/lib/ext
#CPATH=$TOMCAT_EXT/commons-httpclient-3.1.jar:$TOMCAT_EXT/log4j-1.2.16.jar:$TOMCAT_EXT/commons-codec-1.8.jar:mbs.jar:$TOMCAT_ROOT/webapps/tomee/lib/commons-logging-1.1.1.jar:.
CPATH=$LIB_ROOT/lib/*:.

echo $CPATH
javac -cp "$CPATH" ActivemqProducerTopic.java
java -cp $CPATH ActivemqProducerTopic
