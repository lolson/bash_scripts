#!/usr/bin/perl
use strict;
use XML::Simple;
use Data::Dumper;

my $xml = XML::Simple->new();
my $data = $xml->XMLin("FIN/soap_project.xml");

#print Dumper($data);

#foreach my $test ($data->findnodes('//con:mockService')) {
#    print $test->getAttribute('name');
#    if ($test->findnodes('./ADI/@Name[.="movie"]')){
#        print "movie\n";
#    }
#    elsif ($test->findnodes('./ADI/@Name[.="photo"]')){
#        print "photo\n";
#    }
#}
