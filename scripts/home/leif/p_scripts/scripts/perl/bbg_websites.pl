#!/usr/local/bin/perl

# bbg_websites.pl
#
# Author: Timothy Esposito <timothy.esposito@emergentspace.com>
# Description: Downloads websites for the BBG Internet Over Satellite server
#              application using wget and then performs some post-processing steps
#
# Developed with the sponsorship of the Broadcasting Board of Governors (BBG)
# under contract number BBG50-C-12-0023.

use strict;

use Config::Simple;
use Log::Log4perl qw(get_logger);
use Log::Log4perl::Layout;
use Log::Log4perl::Level;
use File::Spec::Functions qw(tmpdir catfile splitdir);
use File::Path;
use File::Copy;
use File::Find;
use File::Basename;
use IO::File;

use constant WGET_OPTS => '-nv --convert-links --page-requisites --span-hosts --timestamping --ignore-length --tries=5 --timeout=30 --restrict-file-names=ascii';


$| = 1;


my $homeDir = $ENV{HOME} || $ENV{USERPROFILE} || (getpwuid($<))[7];

# setup logging
my $logger = get_logger('');

my $stdoutClass = $^O =~ /MSWin/i ? 'Log::Log4perl::Appender::Screen' : 'Log::Log4perl::Appender::ScreenColoredLevels';
my $stdoutAppender = Log::Log4perl::Appender->new($stdoutClass, name => 'screenlog', stderr => 0);
my $layout = Log::Log4perl::Layout::PatternLayout->new('%d{yyyy-DDD-HH:mm:ss.SSS} [%p] %m%n');
$stdoutAppender->layout($layout);
$logger->add_appender($stdoutAppender);
$logger->level($DEBUG);

my $fileAppender = Log::Log4perl::Appender->new('Log::Log4perl::Appender::File',
                                                name => 'filelog',
                                                filename => getLogFileName('bbg_websites'));
$fileAppender->layout($layout);
$logger->add_appender($fileAppender);
# $logger->debug, info, warn, error, fatal


sub getLogFileName {
    my ($basename) = @_;
    my @t = localtime(time);
    my $ts = sprintf("%02d%02d%02dT%02d%02d%02d", substr(1900+$t[5], 2, 2), $t[4]+1, $t[3], $t[2], $t[1], $t[0]);
    my $bbgDir = $^O =~ /MSWin/i ? '_bbg' : '.bbg';
    return catfile($homeDir, $bbgDir, 'log', "${basename}_${ts}.log");
}


sub purgeMainStream {
    my ($mainStream) = @_;
    
    if ($File::Find::name eq "" || !-f $File::Find::name) {
        return;
    }
    
    my $mainFile = catfile($mainStream, basename($File::Find::name));
    
    if (-f $mainFile) {
        #$logger->debug("Removing file from main stream => $mainFile");
        unlink($mainFile);
    }
}


sub copyStreamToMain {
    my ($mainStream) = @_;
    
    if ($File::Find::name eq "" || !-f $File::Find::name) {
        return;
    }
    
    my @dirs = splitdir($File::Find::dir);
    my @subdirs = ( );
    my $gotTag = 0;
    for my $dir (@dirs) {
        if ($gotTag) {
            push @subdirs, $dir;
        } elsif ($dir eq 'index') {
            $gotTag = 1;
        }
    }
    
    my $mainFile = catfile($mainStream, @subdirs, basename($File::Find::name));
    #$logger->info("Copying $File::Find::name to $mainFile");
    copy($File::Find::name, $mainFile);
}


sub moveStreamToMain {
    my ($mainStream) = @_;
    
    if ($File::Find::name eq "" || !-f $File::Find::name) {
        return;
    }
    
    my @dirs = splitdir($File::Find::dir);
    my @subdirs = ( );
    my $gotTag = 0;
    for my $dir (@dirs) {
        if ($gotTag) {
            push @subdirs, $dir;
        } elsif ($dir eq 'audio' || $dir eq 'video') {
            $gotTag = 1;
        }
    }
    
    my $mainFile = catfile($mainStream, @subdirs, basename($File::Find::name));
    #$logger->info("Moving $File::Find::name to $mainFile");
    move($File::Find::name, $mainFile);
}


sub moveMediaFile {
    my ($audioStream, $videoStream) = @_;
    
    if ($File::Find::name eq "" || !-f $File::Find::name) {
        return;
    }
    
    # audio: mp3, wma, rm
    # video: mp4
    
    my ($streamDir);
    
    if ($File::Find::name =~ /\.mp3$/) {
        $streamDir = $audioStream;
    } elsif ($File::Find::name =~ /\.mp4$/) {
        $streamDir = $videoStream;
    } else {
        # ignore all non media files
        return;
    }
    
    my @dirs = splitdir($File::Find::dir);
    my @subdirs = ( );
    my $gotMain = 0;
    for my $dir (@dirs) {
        if ($gotMain) {
            push @subdirs, $dir;
        } elsif ($dir eq 'main') {
            $gotMain = 1;
        }
    }
    
    my $mediaDir = catfile($streamDir, @subdirs);
    
    if (!-d $mediaDir) {
        #$logger->debug("Making directory => $mediaDir");
        mkpath($mediaDir);
    }
    
    my $mediaFile = catfile($mediaDir, basename($File::Find::name));
    #$logger->info("Moving $File::Find::name to $mediaFile");
    move($File::Find::name, $mediaFile);
}


sub processSite {
    my ($sitesDir, $url, $index, $tag, $domains, $levels, $reject) = @_;
    
    $logger->info("Processing web site => $url");
    
    my $mainStream = catfile($sitesDir, $tag, 'main');
    my $indexStream = catfile($sitesDir, $tag, 'index');
    my $audioStream = catfile($sitesDir, $tag, 'audio');
    my $videoStream = catfile($sitesDir, $tag, 'video');
    
    # copy or move index and media files to main stream to prevent re-downloading
    # moving files is less overhead on the filesystem
    if (0 && -d $indexStream) {
        $logger->debug("Copying files from $indexStream to $mainStream");
        find(sub { copyStreamToMain($mainStream) }, $indexStream);
        
        # remove main stream index.html so it will download
        unlink(catfile($mainStream, $tag, $index));
    }
    
    if (-d $audioStream) {
        $logger->debug("Moving files from $audioStream to $mainStream");
        find(sub { moveStreamToMain($mainStream) }, $audioStream);
    }
    
    if (-d $videoStream) {
        $logger->debug("Moving files from $videoStream to $mainStream");
        find(sub { moveStreamToMain($mainStream) }, $videoStream);
    }
    
    # construct index stream
    if (!-d $indexStream) {
        mkpath($indexStream);
    }
    
    my $domain = $url;
    $domain =~ s/http:\/\///;
    $domain =~ s/\/.*//;
    
    my $domainList = '--domains=' . join(',', split(' ', $domains), $domain);
    
    my $rejectOpt = '';
    if (length($reject) > 0) {
        $reject =~ s/\s+/,/;
        $rejectOpt = "--reject=$reject";
    }
    
    sleep 3;
    my $wgetLog = getLogFileName("wget_${tag}_index");
    $logger->debug("$url index stream wget log file => $wgetLog");
    my $cmd = "wget -o \"$wgetLog\" " . WGET_OPTS . " $domainList $rejectOpt $url";
    $logger->info("Executing wget command to build index stream => $cmd");
    chdir($indexStream);
    my $rv = system($cmd);
    
    if ($rv != 0) {
        $logger->error("wget had a failure return value of $rv");
    }
    
    # construct main stream
    if (!-d $mainStream) {
        mkpath($mainStream);
    }
    
    #$logger->info("Pausing script for 1 minute for servers that prevent too many connections");
    #sleep 61;
    sleep 3;
    $wgetLog = getLogFileName("wget_${tag}_main");
    $logger->debug("$url main stream wget log file => $wgetLog");
    $cmd = "wget -o \"$wgetLog\" --recursive --level=$levels " . WGET_OPTS . " $domainList $rejectOpt $url";
    $logger->info("Executing wget command to build main stream => $cmd");
    chdir($mainStream);
    $rv = system($cmd);
    
    if ($rv != 0) {
        $logger->warn("wget had a failure return value of $rv");
    }
    
    # replace index.html in index stream from the main stream, because it has proper links
    $logger->debug("Moving index.html from main to index stream");
    move(catfile($mainStream, $tag, $index), catfile($indexStream, $tag, $index));
    
    # remove files from main stream that are already in index stream
    $logger->debug("Purging index files from main stream");
    find(sub { purgeMainStream($mainStream) }, $indexStream);
    
    # move all audio and video files into thier own streams
    $logger->debug("Moving media files to their own streams");
    find(sub { moveMediaFile($audioStream, $videoStream) }, $mainStream);
    
    # create timestamp file to let SiteWatcher service known when it can start packetizing new site
    my $tsFile = catfile($sitesDir, $tag, 'updated.txt');
    $logger->debug("Writing timestamp file => $tsFile");
    my $tsFH = IO::File->new($tsFile, 'w');
    $tsFH->print(time);
    $tsFH->close;
}


package main;

{

    if (scalar(@ARGV) != 1) {
        print "Usage: $0 \"<SITES_DIR>\"\n";
        exit(1);
    }
    
    my $sitesDir = $ARGV[0];
    
    unless (-d $sitesDir) {
        print "Sites directory must be a valid directory\n";
        exit(2);
    }
    
    my $bbgDir = $^O =~ /MSWin/i ? '_bbg' : '.bbg';
    my $cfgFile = catfile($homeDir, $bbgDir, 'bbg_websites.cfg');
    
    unless (-f $cfgFile) {
        print "Configuration file was not found => $cfgFile\n";
        exit(3);
    }
    
    my $cfg = new Config::Simple($cfgFile);
    my $numSites = $cfg->param('numSites');
    
    my $start = time;
    
    for (my $s = 1; $s <= $numSites; ++$s) {
        print "Sites dir: $sitesDir \n";

        print "Url param("site_${s}.url")";
#         $cfg->param("site_${s}.index"),
#                    $cfg->param("site_${s}.tag"), $cfg->param("site_${s}.domains"),
#                    $cfg->param("site_${s}.levels"), $cfg->param("site_${s}.reject"));
#        processSite($sitesDir, $cfg->param("site_${s}.url"), $cfg->param("site_${s}.index"),
#                    $cfg->param("site_${s}.tag"), $cfg->param("site_${s}.domains"),
#                    $cfg->param("site_${s}.levels"), $cfg->param("site_${s}.reject"));
    }
    
    my $runTime = time - $start;
    my $runTime2 = sprintf("%.2f", $runTime/60); 
    $logger->info("Total run time was $runTime sec ($runTime2 min)");

}


1;

__END__
