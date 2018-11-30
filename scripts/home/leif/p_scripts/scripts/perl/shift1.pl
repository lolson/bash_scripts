use feature say;
@colors = ("red", "orange" , "yellow", "green", "blue", "indigo" , "violet" );
say "                            Display array: @colors";
say "   Display and remove first elem of array: ", shift  (@colors);
say "          Display remaining elem of array: @colors";

push(@colors, "WHITE");
say "Add element to end of array and display: @colors";
say "   Display and remove last elem of array: ", pop (@colors);
say "          Display remaining elem of array: @colors";
@ins = ("GRAY", "FERN");
splice (@colors , 1, 2, @ins);
say "Replace second and third elem of array: @colors";

