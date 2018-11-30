#!/usr/bin/perl -w
#
# author: Ed Koster
# description: Scans a guid file (or all guid files in a directory) and warns
#              if any of the guids are over 50 characetrs long

$MAX_SIZE = 50;


#############################
# verifyFile(String guidFile)
#############################
sub verifyFile {

    open(IN, $_[0]);
    $lineNumber = 1;
    while($line = <IN>) {
	$line =~ s/\s*$//;           # remove trailing whitespace
	if (length($line) > $MAX_SIZE) {
	    printf("Warning: line " . $lineNumber . " of " . $_[0] . " is " .
		   length($line) . " characters long.\n");
	}
	$lineNumber++;
    }
    close(IN);
}


#############################
# verifyDir(String guidDir)
#############################
sub verifyDir {

    chdir  $_[0];
    opendir(DIR, ".");
    my @subdirs = ();  # to keep track of sub-directories

    while ($filename = readdir(DIR)) {
	if (-d $filename &&
	    $filename ne "." &&
	    $filename ne ".." &&
	    $filename ne "CVS" ) {
	    $dir = `pwd`;
	    chop($dir);
	    printf " * Checking directory $dir/$filename\n";
	    push(@subdirs, $filename);
	} elsif (-T $filename && $filename =~ /\.guid/i) {
	    verifyFile($filename);
	}
    }
    closedir(DIR);

    # now recursively check sub-directories
    while ($#subdirs >= 0) {
	verifyDir(pop(@subdirs));
    }
    chdir "..";
}


#############################
# MAIN
#############################

($#ARGV >= 0) || die "Usage: guidVerifier.pl [dir | file]";

$arg = shift;

if (-d $arg) {
    verifyDir($arg);
} elsif (-T $arg) {
    verifyFile($arg);
} else {
    die "Cannot find or open " . $arg;
}


