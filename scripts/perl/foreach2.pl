use feature say;
print "Enter starting number: ";
$start = <>;
print "Enter ending number: ";
$end = <>;
print "Enter increment: ";
$incr = <>;

if ($start >= $end || $incr < 1) {
    die ("The starting number must be less than the ending number\n, 
        and the in must be > 0.\n");
}
#for($count = $start+0; $count <= $end; $count += $incr) {
for($count = chomp($start); $count <= $end; $count += $incr) {
    say "$count";
}

