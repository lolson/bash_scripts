print "Enter a number: ";
$num1 = <>; # read entry from std input and assign to the var $num
# <> is a "magic file handle"
print "Enter another, different number: ";
$num2 = <>;

if($num1 == $num2) {
    die ("Please enter two different numbers.\n");
}
if ($num1 > $num2) {
    print "The first number is greater than the 2nd.\n";
} else {
    print "The first is less than the 2nd number.\n";
}

