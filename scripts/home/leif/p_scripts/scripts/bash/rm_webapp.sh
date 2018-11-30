#!/bin/bash
#WEBAPP=dashboard

rm -Rf $COF_CATALINA_HOME/webapps/$1
rm $COF_CATALINA_HOME/webapps/$1.war
