
open(FIND, "find . -print |") || die "Couldn't run find: $!\n";

FILE:
while ($filename = <FIND>) {
    chop $filename;
    next FILE unless -T $filename;
    if (!open(TEXTFILE, $filename)) {
        print STDERR "Can't open $filename -- continuing ...\n";
        next FILE;
    }
    while (<TEXTFILE>)  {
        foreach $word (@ARGV) {
            if (index($_, $word) >= 0) {
                print $filename, "\n";
                next FILE;
            }
        }
    }
}
