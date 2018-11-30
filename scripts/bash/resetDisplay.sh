#!/bin/bash
#To reset unfunctional display, in particular when rebooting from multimonitor mode
#run as root
sudo cp /etc/X11/xorg.conf.stable /etc/X11/xorg.conf
sudo restart lightdm
