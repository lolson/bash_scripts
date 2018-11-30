use feature say;
@arrayvar = (8, 18, "Sam");
# say $arrayvar[1];
# say "@arrayvar[1,2]";

@arrayvar2 = ("apple", "bird", 44, "Tike", "metal", "pike");

$num = @arrayvar2; # number of elems in array
print "Elements: ",$num, "\n"; # two equivalent print stmts
print "Elements: $num\n";
print "Last: $#arrayvar2\n"; # index of last elem in array

$v1 = 5; $v2 = 8;
$va = "Sam"; $vb = "uel";
@array3 = ($v1, $v1 * 2, $v1 * $v2, "Max", "Zach", $va . $vb);

print $array3[2], "\n";
say $array3[2];

print @array3[2,4], "\n";  # two elements of an array are a list
print @array3[2..4], "\n\n";
#say "@array3[2..4]";
print "@array3[2,4]", "\n";  # two elements separated by spaces

print "@array3[2..4]", "\n\n";
print "@array3\n";

