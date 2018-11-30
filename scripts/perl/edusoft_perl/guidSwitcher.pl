#!/usr/bin/perl -w

$guidsFile = shift;
$guidDir = shift;

$javaCmd = "java com.edusoft.admin.guid.GuidSwitcher ";

# print "reading from '$guidsFile', dir = '$guidDir'\n";

# print "$javaCmd\n";

open(IN, $guidsFile);

while($line = <IN>) {
    ($old, $new) = split(/\|/, $line, 2);
    
    print ($javaCmd." ".$old." ".$new." ".$guidDir."\n");
}

close(IN);
