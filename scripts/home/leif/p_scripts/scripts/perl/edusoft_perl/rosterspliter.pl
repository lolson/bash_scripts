#!/bin/perl
use warnings; 
use strict;

if($#ARGV ne 2 ) {
    print "usage : rosterspliter.pl rosterfiletosplit column_number text_for_new_filename   
(example: rosterspliter.pl jdusd02-03.txt 1 02-03)";      
    exit;
}

open (IN , "< $ARGV[0]");
my $COL_NUM = $ARGV[1] - 1;
my $APPEND_TXT = $ARGV[2];

my @data = <IN>;

close(IN );

my $currentfile= "";

foreach my $line (@data){
  my @tokens=split(/\t/,$line);
  if($#tokens < 3 ){
    @tokens=split(/,/,$line);
  }
  $tokens[$COL_NUM]=~s/ //g;
  chomp(@tokens);
  if($tokens[$COL_NUM] eq $currentfile){
    print SCHOOL $line;
  } else {
    close(SCHOOL );
    open (SCHOOL, "> $tokens[$COL_NUM].$APPEND_TXT.txt");
    $currentfile=$tokens[$COL_NUM];
  }
}
close(SCHOOL );



