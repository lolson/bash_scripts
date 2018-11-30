#!/bin/sh
# Show available memory, similar to Linux free
# 256 is the num of pages in a megabyte
# 256 pages * 4096 bytes / page = 1048576 bytes
# Aka 2^20 bytes which == 1 MB, give 1 page is 4096 bytes

vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages\s+([^:]+)[^\d]+(\d+)/ and printf("%-16s % 16.2f M\n", "$1:", $2 * $size / 1048576);'
