#!/bin/bash

sudo -i
mkdir /tmp/vmware && cd /tmp/vmware
# cp -R /usr/lib/vmware/modules/source/
cp -R /usr/lib/vmware/modules/source/ /tmp/vmware
cd /tmp/vmware/source
wget http://weltall.heliohost.org/wordpress/wp-content/uploads/2011/05/vmware2.6.39patchv3.tar.bz2
tar -jxvf vmware2.6.39patchv3.tar.bz2
for i in ./*.tar; do tar -xf $i; done
for i in ./*.tar; do mv $i $i.orginal; done
patch -t -f -p1 < vmware2.6.39fixedv3.patch
tar cf vmblock.tar vmblock-only
tar cf vmci.tar vmci-only
tar cf vmmon.tar vmmon-only

