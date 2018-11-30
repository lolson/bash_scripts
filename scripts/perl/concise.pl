my $regex="^[for]";
#while ( my $line =<>) {
#    chomp $line;
#    if ($line =~ /$regex/) {
#        print "Found : $line \n\n";
#    }
#}

#while (my $_ =<>) {
#    chomp $_;
#    if($_ =~ /$regex/) {
#        print "Found : $_ \n\n";
#    }
#}

while (<>) { # read into $_
    chomp; # chomp $_
    if(/$regex/) { # if $_ matches regex
        print "Found : $_ \n\n";
    }
}
