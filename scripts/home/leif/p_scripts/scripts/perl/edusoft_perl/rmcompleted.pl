#!/usr/bin/perl -w

#
# Removes all 'completed="*"' attributes from the XML file.
#
# First it runs pretty_xml.sh on the file, because it relies
# on the resulting format.
#
# usage: rmcompleted.pl [-b] <xml>
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

# Run pretty_xml.sh (requires that it is in the path)
`pretty_xml.sh $original`;

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
    if($line !~ /completed/) {
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
