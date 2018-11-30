#!/bin/bash
# -r recursive
# -l specify max recursion depth level 
# -k convert links to make them suitable for local viewing
# -nH removes directory site prefix ftp.xemacs.org/pub/xemacs/ -> pub/xemacs/
# Args: 1) managed_site folder, bbg.managed.dir 2) website name
# Array of website names, use perl script?
BBG_MANAGED_DIR=$1
wget -r -l 1 -k -nH http://ir.voanews.com/
