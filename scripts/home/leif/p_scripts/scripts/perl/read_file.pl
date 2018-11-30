
#!/usr/bin/perl
use integer;
$num_args = $#ARGV + 1;
if ($num_args != 1) {
    print "\nUsage: readf.pl filename\n";
    exit;
}
my $filename = $ARGV[0];

if (open(my $fh, '<:encoding(UTF-8)', $filename)) {
  my @rows;
  while (my $row = <$fh>) {
    chomp $row;
    my $len =  length $row;
    my $octet = $len/8;    
    print "Length : $len,\t Octet : $octet \n";
    push(@rows, $row); 
  }
    my $count = scalar(@rows);
    print "Segments count: \t $count \n";    
} else {
  warn "Could not open file '$filename' $!";
}
close($fh);

