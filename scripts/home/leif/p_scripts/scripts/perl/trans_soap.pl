use strict;
use warnings;

my $DATE = `date +%y%m%d"-"%H%M%S`;
my $tstamp = "";

#my $HOSTNAME = "127.0.0.1";
my $HOSTNAME="192.168.10.73";
#my $PORT = "8080";
my $PORT = "8443";
my $OUT = "";

 
sub process_jms_soap {
    open (DEST, "> $OUT") || die "Can't open $OUT: $!\n";
    my $file = shift;
    open (FILE, $file) || die "Can't open $file: $!\n";
    while (my $line = <FILE>) {
        $line =~ s/name="JMS_SP5_Demo"/name="JMS_SP5_Demo_$tstamp"/g; # change soap project name
        $line =~ s/host="[\w-]*"/host="$HOSTNAME"/g; # find/rplc attr host="PHoeve-PC"
        $line =~ s/port="[\d]*"/port="$PORT"/g; # find/rplc globaly on line for any length digit port attribute
        print DEST $line;
    }
    close (DEST);
    close (FILE);
}

sub setup {
    $tstamp = $DATE;
    $tstamp =~ s/\n//g;
    $OUT = "OUT/JMS-soapui-project-trans-$tstamp.xml";
#    print $OUT;
    while (my $file = shift) {
        process_jms_soap $file;
    }
}

setup @ARGV;

# print the files given as cmd ln args
