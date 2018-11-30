#!/usr/bin/perl -w
#
# author: Ed Koster
# description: Comments out the assesment and section tag info of eduContent
#              xml data files to make them just a series of question-sets.
#              This makes them previewable.  Does this for all xml files in a
#              specified directory or for the specified file.  Warning: it does
#              correctly handle already commented files, so only do this once
#              for any xml file

$TEMP_XML_FILE = "temp.xml";


#############################
# String commentHeaders()
# -----------------------
# comments out the assessment and section tage headers in the given xml file.
#############################
# note about my regexps: i used m_<pattern>_ instead of /<pattern>/ separators
#                        since some of the patterns contain a backslash
#                        

sub commentHeaders {
    open(IN, $_[0]);
    open(OUT, ">$TEMP_XML_FILE");
    while($line = <IN>) {

        # start commenting before <assessment> or </section>
	if ($line =~ m%.*<(assessment|/section)>.*%i) {
	    print OUT "<!--\n";
	}

	print OUT $line;

	# stop commenting after <section sequence=...> or </assessment>
	if ($line =~ m%.*<(section sequence=.*|/assessment)>.*%i) {
	    print OUT "-->\n";
	}
    }
    close(OUT);
    close(IN);
    rename($TEMP_XML_FILE, $_[0]);
}


#############################
# MAIN
#############################

($#ARGV >= 0) || die "Usage: eduContentHeaderCommenter.pl [dir | file]";

$arg = shift;

if (-d $arg) {
    chdir $arg;
    opendir(DIR, ".");
    while ($filename = readdir(DIR)) {
	if (-T $filename && $filename =~ /\.xml$/i) {
	    commentHeaders($filename);
	}
    }
    closedir(DIR);
} elsif (-T $arg) {
    commentHeaders($arg);
} else {
    die "Cannot find or open " . $arg;
}















