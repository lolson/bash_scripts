#!/usr/bin/perl
# Intended to process like ONE_LINE_2015344223902.IHK that was created by:
#
# xxd -b O1_2015344223902.IHK | awk -F '[ ]' '{print $2,$3,$4,$5,$6,$7}' OFS="," | sed -e 's/,//g' | tr -d '\n > ONE_LINE_2015344223902.IHK
# see 461-SYS-ICD-0010H_tlm_cmd_format.pdf, section #.O telemetry

use integer;
$num_args = $#ARGV + 1;
if ($num_args != 1) {
    print "\nUsage: readWrap.pl filename\n";
    exit;
}
my $filename = $ARGV[0];
my $tmp1 = 'one_line_tlm.txt';
my $tmp2 = 'segment_file.txt';
my $header_len = 16;

# escape $ and " symbols to be passed to awk, create single line of literals 0 and 1
system("xxd -b $filename | awk -F '[ ]' '{print \$2,\$3,\$4,\$5,\$6,\$7}' OFS=\",\" | sed -e 's/,//g' | tr -d '\n' > $tmp1");
# find occurences of the pattern of supposed header bounding some 
system("cat $tmp1 | grep -P -o '(01)(00110001)(000001)(.*?)(01)(00110001)(000001)' > $tmp2");

if (open(my $fh, '<:encoding(UTF-8)', $tmp2)) {
  my @rows;
  while (my $row = <$fh>) {
    chomp $row;
    my $len =  length $row;
    my $octet = $len/8;
    my $frame_size = $len - $header_len;
    my $frame_octet = $frame_size/8;

    print "Total (b) : $len,\t Oct : $octet, \t Frame (b): $frame_size, \t Frame oct: $frame_octet \n";
    push(@rows, $row); 
  }
    my $count = scalar(@rows);
    print "Segments count: \t $count \n";    
} else {
  warn "Could not open file '$tmp2' $!";
}
close($fh);

#remove temp file
unlink($tmp1);
unlink($tmp2);
