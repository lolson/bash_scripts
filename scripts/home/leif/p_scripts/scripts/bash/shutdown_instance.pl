#!/bin/perl
#use warnings;

my @uuids;
my @d;
my %uuid_map;
my $nova_list = "nova_list.txt";
my $qemu_ps = "qemu_ps.txt";
my $instance_ps;

system("nova list > $nova_list");

open($fh, '<', "$nova_list")
  or die "can't open $!\n";

while (my $row =<$fh>) {
  chomp $row;
  @d = split (/\|/, $row);
  if($d[1] =~ !/ID/) {
     push(@uuids, $d[1]);
     $uuid_map{$d[1]} = $d[2];
  }
}

$fh->close;

while( my ($key, $value) = each(%uuid_map) ) {
  print "$key => $value\n"
}

system("ps -elf | grep qemu > $qemu_ps");

open($fh, '<', "$qemu_ps")
  or die "can't open $!\n";

while (my $row =<$fh>) {
  chomp $row;
  keys %uuid_map;
  while(my($uuid, $name) = each %uuid_map) {
     if($row =~ /$uuid/) {
        chomp $row;
        @col = split /\s+/, $row;
        print "Process is: $col[3]\n";
        $instance_ps = $col[3];
     }
  }
}

system("kill -9 $instance_ps");

cleanup();

