#!/bin/bash
# process mysql update script given as single arg
# find scripts under ~/svn_checkout/nexus/trunk/db/updates

mysql -u nexus -p -h localhost nexus < $1
