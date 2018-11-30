#!/bin/bash

#java -cp /opt/jboss-as-7.1.1.Final/bin/client/jboss-client.jar:. JMXAccess 9999
java -cp /opt/jboss-as-7.1.1.Final/bin/client/jboss-client.jar:. TestMBeanServiceMonitor localhost 9999
