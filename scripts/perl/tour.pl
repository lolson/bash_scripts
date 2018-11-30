#!/usr/bin/perl
#use utf8;  support unicode
#use feature ':5.10';  use newer version perl features like say func

@lines=`perldoc -u -f atan2`;
foreach (@lines) {
   s/\w<([^>]+)>/\U$1/g;
   print;
}
