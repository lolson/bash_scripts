while ($line = <>) {
    print $., ". $line"; # the $ variable keeps track of the number of lines
}
print "\n$. lines entered.\n";

