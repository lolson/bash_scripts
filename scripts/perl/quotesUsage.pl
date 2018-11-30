$string="5";
print '$string+5\n'; # displayed literally because of single quotes
print "\n$string+5\n"; # interpolates $string because of dbl quotes
print $string+5, "\n"; # lack of quotes cause perl to interpret $string as numeric

