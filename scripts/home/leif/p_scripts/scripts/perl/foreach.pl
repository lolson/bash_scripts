use feature say;
foreach $item ("Mo", "Larry", "Curly") {
    say "$item says hello.";
}
@stooges = ("Moe", "Larrie", "Kurlie");
foreach (@stooges) {
    say "$_ says hello.";
}
for (@stooges) {
    say "$_ says hello.";
}
