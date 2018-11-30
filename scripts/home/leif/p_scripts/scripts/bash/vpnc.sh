#!/bin/bash
if [[ "$1" == help || "$1" == "-help" || "$1" == "--help" ]]; then 
    echo ""
    echo "Shell script to run command line VPN client" 
    echo "vpnc-connect /etc/vpnc/grnconf.conf"
    echo "If successful:"
    echo "VPNC started in background (pid: 10975)..."
    echo ""
    echo "To disconnect vpnc-disconnect"
    echo ""
else
    sudo vpnc-connect /etc/vpnc/grnconf.conf
fi
