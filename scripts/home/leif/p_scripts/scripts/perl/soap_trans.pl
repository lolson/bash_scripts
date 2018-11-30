use strict;
use warnings;
 
sub read_file {
    my $file = shift;
    open FILE, $file;
    while (my $line = <FILE>) {
        $line =~ s/name/NAME/g;
        print $line;
    }
}

sub prn {
    while (my $file = shift) {
        read_file $file;
    }
}

prn @ARGV;

# print the files given as cmd ln args
