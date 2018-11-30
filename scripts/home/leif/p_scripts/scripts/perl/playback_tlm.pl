#!/usr/bin/perl

use Config::IniFiles;
my $config_file = '/mission/mms/config_data/input.config';
my $mission_data_dir = '/moc/tlm/MMS1/high-priority/';

sub kill_ffs_decode {
	my $res = 'res.txt';
	system("ps -ef | grep 'feds' | grep 'FFS_decode 1 I' | grep -v 'grep' | awk '{print \$2}' > $res");
	if (open(my $fh, '<:encoding(UTF-8)', $res)) {
		while (my $ps =<$fh>) {
			chomp $ps;
			print "killing pid: $ps\n";
			system("kill -9 $ps");
			print "after killing $ps\n";
		}
	} 
	unlink($res);
}

sub kill_playback_ps {
	my $pid = 'pid.txt';
	system("ps -ef | grep 'feds' | grep 'perl playback' | grep -v 'grep' | awk '{print \$2}' > $pid");
	my @playback_ps;

	if (open(my $fh_p, '<:encoding(UTF-8)', $pid)) {
		while (my $ps =<$fh_p>) {
			chomp $ps;
			# Don't include this process itself which is $$
			if($ps ne $$) {
				push(@playback_ps, $ps);
			}
		}
	} 
	unlink($pid);

	foreach my $p_ps (@playback_ps) {
		print "Found running playback tlm ps: $p_ps\n";
		system("kill -9 $p_ps");
	}
}

# Make a system call to FFS_decode to playback tlm file 
# configured by input.config. This program takes the args:
# FFS_decode $s $pchan $fl $comment
# For instance:
# FFS_decode 1 I 1128
# See $FEDS_scripts/feds.startup 
sub playback_tlm {
	kill_ffs_decode;
    my $p1 = shift @_;	
    my $cmd = 'FFS_decode 1 I 1128';
	eval {
		local $SIG{'ALRM'} = sub { die "timed out\n" };
		alarm(10);
    	system($cmd) or die "system call failed";
		alarm(0);
	};
	if ($@) {
		if ($@ eq "timed out\n") {
			print "Alarm timed out. \n";  
		}
		else {
			print "Something else failed\n";
		}
	}
    print "Done with $p1. \n\n";
}	

sub playback_tlm2 { # just sits
    my $p1 = shift @_;	
	@result = `FFS_decode 1 I 1128`;
	foreach my $line (@result) {
		print "Result: $line";
	}
#    open (my $fh, "-|",  'FFS_decode 1 I 1128')  or die "Failed";
#		while( my $line = <$fh>) {
#			print "Processed: $line";
#		}
	
}

# Rewrite the path of the input telemetry file name
# set in input.config. This configuration is used
# by the program FFS_decode
sub rewrite_input_config {
    my @file_name = @_;
    my $cfg = Config::IniFiles->new( -file => $config_file );
    $cfg->setval( 'all', 'FILE_NAME', @file_name[0]  );
    # print "The changed file name is " .$cfg->val( 'all', 'FILE_NAME' ). "\n";
    $cfg->RewriteConfig();
}

sub read_tlm_dir { #TODO have one pass look for IHK and another SCH
    my $dir = $mission_data_dir;
    opendir(DIR, $dir) or die "cannot open dir $dir: $!";
    # read contents of data directory into array
    # use of perl's grep to include only tlm file types
    my @files = grep { $_ =~ /.*((IHK)|(SCH))$/ } readdir DIR;
    closedir DIR;
    # iterate over array
    foreach my $file (@files) { 
        # get fully qualified file names
        my $full_path = join('',$dir, $file);
        # print "$full_path\n";
        rewrite_input_config $full_path;
        playback_tlm $full_path;
    };
}

kill_playback_ps;
read_tlm_dir; 

#playback_tlm "empty";
#kill_ffs_decode;
