#!/bin/bash
DATE=`date "+%Y-%m-%d"`

mysqldump -u nexus -pnexus nexus > ~/db_dumps/myNexusDBImage$DATE.mysql
