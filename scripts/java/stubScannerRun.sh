#!/bin/bash
CPATH=/home/leif/svn_checkout/mbs/trunk/ws/dist/mbs-ws.jar
STUBDIR=/home/leif/svn_checkout/mbs/trunk/jms/client/lib
STUBJAR=/home/leif/svn_checkout/mbs/trunk/jms/client/lib/SPADOCServiceSOAPBindingQSService-test-client.jar
MSGS=/home/leif/tmp

java -cp $CPATH com.emergentspace.mbs.ws.StubScanner 
