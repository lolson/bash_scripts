# Process exported HTML from Freemind
# output format in an outline format
# Quit unless we have the correct number of command-#line args
$num_args = $#ARGV + 1;
if ($num_args != 1) {
    print "\nUsage: process_freemind.pl freemind_export.txt\n";
    exit;
}
my $MM_FILE = $ARGV[0];
print "Openning file $MM_FILE\n";

open my $fh, '<', $MM_FILE 
 or die "Cannot read $MM_FILE \n";
open my $out, '>', 'output.txt';  

my $index = 1;
my $letter = a;
my $subDash = 1;
while(<$fh>) {
    chomp;
    my $line = $_;
    $line =~ /^(\s*)/;
    my $spaces = length( $1 ); # count whitespace
    $orig_line = $line; 
    $line =~ s/^(\s*)//; # remove empty lines
    #$line =~ s/^\s*./\U$1\E/; # Capitalize first letter from a paragraph/new line
    #$line =~ s/(\s|^)\w/\U$&\E/g ; # Capitalize first letter from a paragraph/new line
    $line =~ s/^\w/\U$&\E/g ; # Capitalize first letter from a paragraph/new line
    if($spaces == 0 && $orig_line !~ /^\s*$/) 
    {
        #print "$spaces, Zero tab\n";
        print "$index. $line\n";
        print $out "$index. $line\n";
        $index += 1;
        $letter = a;
    }
    elsif ($spaces == 4)
    {
        #print "$spaces, one tab\n";
        print "    $letter. $line\n";
        print $out "    $letter. $line\n";
        $letter ++;
    }
    elsif ($spaces == 8)
    {
        #print "$spaces, more that 4 spaces, use a dash\n";
        print "        - $line\n"; 
        print $out "        - $line\n";
        $subDash = 1;
    } 
    elsif ($spaces == 12)
    {
        print "            $subDash. $line\n"; 
        print $out "            $subDash. $line\n"; 
        $subDash += 1;
    }
    elsif ($spaces > 12)
    {
        print "                - $line\n"; 
        print $out "                - $line\n"; 
    } 
}
