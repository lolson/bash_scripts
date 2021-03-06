#! /bin/bash
# Fix Ubuntu Plymouth Boot Splash 
# if entry exists for $vt_handoff use sed to search and replace
# write to tmp file - move to original 

checkVT=$(grep -c "\$vt_handoff" /boot/grub/grub.cfg)

if [ ! "$checkVT" -eq "0" ] 
   then
     echo "> Found vt_handoff removing ..."
     sudo sed 's/$vt_handoff//g' /boot/grub/grub.cfg > /tmp/.grub.cfg
     sudo mv /boot/grub/grub.cfg /boot/grub/grub.cfg.backup
     sudo mv /tmp/.grub.cfg /boot/grub/grub.cfg
   fi

echo "> Done"
