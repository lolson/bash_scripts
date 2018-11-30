#!/bin/bash
AR=build/dist/cof-pub.jar
CPATH=$COF_CATALINA_HOME/apps/cof/cof-ejb.jar:$COF_CATALINA_HOME/apps/cof/lib/cof.jar:$JAR
CPATH=$COF_CATALINA_HOME/webapps/tomee/lib/openejb-client-4.7.1.jar:$CPATH
CPATH=$COF_CATALINA_HOME/webapps/tomee/lib/javaee-api-6.0-6-tomcat.jar:$CPATH
#echo $CPATH

java -cp $CPATH gov.nasa.gsfc.cof.openstack.OpenStackMetricsClient 127.0.0.1 8443

