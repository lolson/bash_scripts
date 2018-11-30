while (<>) {
    chop;
    if ($_ ne "") { # $_ is default operand
        print $_,"\n";
    }
}
