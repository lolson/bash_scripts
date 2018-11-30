#!/bin/bash
tar cvpzf backup.tgz ~
#tar cvpzf backup.tgz ~ --exclude=~/vmware


# back up from slash
#tar cvpzf backup.tgz --exclude=/proc --exclude=/lost+found --exclude=/backup.tgz --exclude=/mnt --exclude=/sys /

