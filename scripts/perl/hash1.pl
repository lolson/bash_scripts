use feature say;
$hashvar{boat} = "tuna";
$hashvar{"number five"}=5;
$hashvar{4} = "fish";

@arrayhash = %hashvar;
print "@arrayhash";
print "\n";
print"@arrayhash[0]\n";
print"@arrayhash[1]\n";

%hash2 =  (
    boat => "tuna",
    "number five" => 5,
    4 => "fish",
);
@array_keys = keys(%hash2);
say " Keys: @array_keys";
@array_values = values(%hash2);
say "Values: @array_values";


