#!/bin/bash
NAME=`hostname`
mutt -s "From $NAME" -a $1 leif.olson@trilliantinc.com < /home/unityadm/scripts/mail_text.txt

