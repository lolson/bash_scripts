#!/bin/bash
# check if ear file and exploded directory exist
# if so, delete them and copy new ear from home
cd $COF_CATALINA_HOME/apps
if [ -e cof.ear ]
   then 
   rm cof.ear
fi
if [ -d cof ]
   then 
   rm -Rf cof
fi
cp ~/cof.ear $COF_CATALINA_HOME/app
