#!/bin/bash
#TOMCAT_ROOT=/home/leif/opt/mbs-tomcat-7.0.40
#TOMCAT_EXT=$TOMCAT_ROOT/lib/ext
#CPATH=$TOMCAT_EXT/commons-httpclient-3.1.jar:$TOMCAT_EXT/log4j-1.2.16.jar:$TOMCAT_EXT/commons-codec-1.8.jar:mbs.jar:$TOMCAT_ROOT/webapps/tomee/lib/commons-logging-1.1.1.jar:.
CPATH=$CATALINA_HOME/lib/*:$CATALINA_HOME/lib/ext/*:$CATALINA_HOME/webapps/tomee/lib/commons-logging-1.1.1.jar:.
#TRUSTSTORE=$TOMCAT_ROOT/work/mbs/wso2-client-truststore.jks
TRUSTSTORE=$CATALINA_HOME/work/mbs/wso2-client-truststore.jks
TRUSTSTORE_PASS="AByXR1dKlXlHj03aBPKTFg==\n"

#exec `jar tf $TOMCAT_EXT/mbs.jar` 
echo $CPATH
javac -cp "$CPATH:mbs.jar" TestHttpClient.java
java -cp $CPATH TestHttpClient TRUSTSTORE TRUSTSTORE_PASS
