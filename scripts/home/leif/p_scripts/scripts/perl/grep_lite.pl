$pattern = shift(@ARGV); # extract first arg into $pattern
while(<>) {              # treat rest of @ARGV as filenames
    if(/$pattern/) {     # if pattern matches
        print;           # print the line
    }
}
