#!/bin/bash

cd ~/scripts/bash 

source ~/.bashrc

gnome-terminal --tab --working-directory=/home/leif/svn_checkout/nexus/trunk/bin \
--tab --working-directory=/home/leif/gems/gems-tomcat-7.0.47/logs \
--tab -t netbeans -e ./run_netbeans.sh

#gnome-terminal --tab -t netbeans -e ./run_netbeans.sh \
#--tab -t tomcat -e cdnex \
#--tab -t tlog -e ./tail_gems.sh \
