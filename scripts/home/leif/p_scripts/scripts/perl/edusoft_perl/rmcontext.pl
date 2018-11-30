#!/usr/bin/perl -w

#
# Removes all 'context' tags from the XML file.
#
# usage: rmcontext.pl [-b] <xml>
# specify option '-b' if you want to make a backup of the original file
#

my $original;
my $output;
my $backup;
my $dobackup = "false";

if($#ARGV == 1) { # there are 2 arguments
    if($ARGV[0] eq "-b") {
        $dobackup = "true";
    }
    $original = $ARGV[1];
}
elsif($#ARGV == 0) { # there is 1 argument
    $original = $ARGV[0];
    if($original =~ /^-/) {
        usage();
    }
}
else {
    usage();
}

$output = $original;
if($dobackup eq "true") {
    $backup = $original.".bak";
}

# I took this from xmlpp.pl -- hopefully it works well
# This treats every tag as a separate line.
# set line separator to ">" speeding up parsing of XML files
# with no line breaks 
$/ = ">";

open(INPUT, "<$original");
@lines = <INPUT>;
close(INPUT);

if($dobackup eq "true") {
    open(BACKUP, ">$backup");
    print BACKUP @lines;
    close(BACKUP);
}

open(OUTPUT, ">$output");

foreach $line (@lines) {
    if($line !~ /context/) {
        print OUTPUT $line;
    }
}

close(OUTPUT);


sub usage {
    print STDERR <<EOF;
usage: $0 [-b] <xml>
specify option '-b' if you want to make a backup of the original file

EOF
    exit 1;
}
