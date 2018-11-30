#!/bin/bash

cd ~/scripts/bash 

source ~/.bashrc

gnome-terminal --tab -t netbeans -e ./run_netbeans.sh \
--tab -t tomcat \
--tab -t tlog -e ./tail_log.sh \
