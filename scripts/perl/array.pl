use feature say;
@array = (8, 18, "Sam");
say $array[0];
say $array[2];
print "@array[1,2]", "\n";
print "@array[0..2]", "\n";

@colors = ("red", "orange", "yellow", "green", "blue", "indigo", "violet");
say "                             Display array: @colors";
say " Display and remove first element of array: ", shift (@colors);
say "       Display remaining elements of array: @colors";

push (@colors, "white");
say "   Add element to end of array and display: @colors";

say " Display pop: ", pop(@colors);

@ins = ("GRAY", "FERN");
splice (@colors, 1, 2, @ins);
say "Replace second and third elements of array: @colors";
