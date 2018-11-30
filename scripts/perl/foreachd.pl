use feature say;
@stooges = ("mo", "larry", "curly");
foreach $stooge (@stooges) {
    $stooge = uc $stooge; # uc is upper case function
    say "$stooge says hello.";
}
say "$stooges[1] is uppercase"
