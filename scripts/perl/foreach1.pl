use feature say;
foreach $item ("one", "two", "three", "four") {
    if($item eq "two") {
        #next; # ;like "break"
        last; #exit the loop, like "continue" 
    }
    say "$item";
}
