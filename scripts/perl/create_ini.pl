#!/usr/bin/perl

use Config::IniFiles;
my $config_file = '/home/leif/stage/input.config';
my $mission_data_dir = '/home/leif/stage';

# Make a system call to FFS_decode to playback tlm file 
# configured by input.config. This program takes the args:
# FFS_decode $s $pchan $fl $comment
# For instance:
# FFS_decode 1 I 1128
# See $FEDS_scripts/feds.startup 
sub playback_tlm {
    system();
}

# Rewrite the path of the input telemetry file name
# set in input.config. This configuration is used
# by the program FFS_decode
sub rewrite_input_config {
    my @file_name = @_;
    print "File name : @file_name[0] \n";
    my $cfg = Config::IniFiles->new( -file => $config_file );
    print "The file name is " .$cfg->val( 'all', 'FILE_NAME' ). "\n";
    $cfg->setval( 'all', 'FILE_NAME', @file_name[0]  );
    print "Now the file name is " .$cfg->val( 'all', 'FILE_NAME' ). "\n";
    $cfg->RewriteConfig();
}

sub read_tlm_dir {
    my $dir = $mission_data_dir;
    opendir(DIR, $dir) or die "cannot open dir $dir: $!";
    # read contents of data directory into array
    # use of perl's grep to include only tlm file types
    my @files = grep { $_ =~ /.*(IHK)|(SCH)/ } readdir DIR;
    closedir DIR;
    # iterate over array
    foreach my $file (@files) { 
        # get fully qualified file names
        my $full_path = join('',$dir, $file);
        print "$full_path\n";
        rewrite_input_config $full_path;
    # rewrite input.config 
    # make system call to FFS_decode, which just ends
    };
}

read_tlm_dir; 

