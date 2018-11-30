#!/bin/bash
RAR=hornetq-rar.rar
rm $RAR
#zip -r $RAR META-INF/* *.*
jar cvfm $RAR META-INF/MANIFEST.MF .
#rm $JBOSS_HOME/standalone/deployments/$RAR.*
rm /home/leif/svn_checkout/nexus/trunk/lib/$RAR
cp $RAR /home/leif/svn_checkout/nexus/trunk/lib
#rm ~/svn_checkout/$JBOSS_HOME/standalone/deployments/$RAR.*
#cp $RAR $JBOSS_HOME/standalone/deployments
cd /home/leif/svn_checkout/nexus/trunk
ant super
echo "Deployed " $RAR
