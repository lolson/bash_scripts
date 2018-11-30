#!/usr/local/bin/perl
#
# perl script to replace strings in multiple files.
#
# written by Rainer Hillebrand
# (rainer.hillebrand@muenster.de, http://www.muenster.de/~hillebra/)
#
# It is being placed in the public domain. It may be
# used for commercial use only by prior arrangement with
# the author.  It may not in any circumstances be resold to
# another party.  You are free to make non-commercial use of
# the ideas and algorithms that this code represents as long
# as you do not merely re-phrase it or port it to another
# language.  If you use any of the code from this program in
# another program, that resulting program must be placed
# under the GNU Copyleft or similar agreement and source code
# from that program must be made available to all who want it.
#
#
# Version 0.1,  99-01-15
#  first rough version
#
# usage:   perl replace.pl <directory> <pattern_file>
# example: perl replace.pl /work/rh/publikom.www /temp/pattern.txt
#
# <directory> is the source of the directory tree
# <pattern_file> is the file containing the patterns to be be replaced.
#    A whitespace separates the old string and the new string.
#    An example in one file:
#
#      oldpattern newpattern
#      second_oldpattern second_newpattern
#
#----------There is nothing to change for you below this line------

$directory = $ARGV[0];
$patternfile = $ARGV[1];

if (($directory || $patternfile) eq "") {
   die("usage: perl replace.pl <directory> <pattern_file>\n")
}

&readpatternfile;

&scan_files($directory);

&replacepattern;

#--------------------------------------------------------------------------
sub  readpatternfile {
  undef @patterns;
  if (-f $patternfile) {
    open(PATTERN,"<$patternfile") || return;  #there are no files or directories to be ignored
    while (<PATTERN>) {
      chomp;
      s|\?|\\\?|;
      push @patterns,$_;
    }
    close PATTERN;
  }
}
#--------------------------------------------------------------------------
sub  scan_files {
   my ($scandir) = @_;
   my (@scandirs,@files,$newdir,$list);
   opendir(DIR,$scandir) || warn "can't opendir $scandir: $!\n";
   @scandirs=grep {!(/^\./) && -d "$scandir/$_"} readdir(DIR);
   rewinddir(DIR);
   @files=grep {!(/^\./) && -f "$scandir/$_"} readdir(DIR);
   closedir (DIR);
   for $list(0..$#scandirs) {
      $newdir=$scandir."/".$scandirs[$list];
      &scan_files ($newdir);
   }
   for $list(0..$#files) {
      $_ = $files[$list];
      next if ((/\.gif/ || /\.jpeg/ || /\.jpg/ || /\.class/));
      push (@filesfound, "$scandir/$files[$list]");
   }
   return 1;
}
#--------------------------------------------------------------------------
sub replacepattern {
	foreach $source (@filesfound) {
      undef @newfile;
      open (FILE,"<$source") || die "Can't open $source: $!.";
      @file = <FILE>;
      close FILE;
      foreach $line (@file) {
	      foreach $string (@patterns) {
   	      ($old,$new) = split(' ',$string);
         	if ($line =~ s|$old|$new|gsx) {print $line;}
	      }
         push @newfile,$line

      }
      open (FILE,">$source") || die "Can't open $source: $!.";
      print FILE @newfile;
      close FILE;
   }
}
