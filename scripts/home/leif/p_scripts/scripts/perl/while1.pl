$count=0;
while($line=<>){
    print ++$count, ". $line";
}
print "\n$count lines entered.\n";

