#!/bin/perl
#
# This script has been adapted from two separate perl scripts by me (Ed).
# For it to work properly you need perl, dvips (comes with LaTeX), and gs.
#
# Proper Usage:
#     tex2gif -path TEX_SOURCE_AND_OUTPUT_PATH [-out OUTPUT_FILENAME] tex_file
#
##########################################################################
#                          T E X T O G I F
#
#               by John Walker -- kelvin@fourmilab.ch
#                     <http://www.fourmilab.ch/>
#
#                    Release 1.0 -- 30th May 1995
#
#
#   Converts a LaTeX file containing equations(s) into a GIF file for
#   embedding into an HTML document.  The black and white image of the
#   equation is created at high resolution and then resampled to the
#   target resolution to antialias what would otherwise be jagged
#   edges.
#
#   Online documentation with sample output is available on the Web
#   at <http://www.fourmilab.ch/webtools/textogif/textogif.html>.
#
#   Write your equation (or anything else you can typeset with LaTeX)
#   in a file like:
#
#       \documentclass[12pt]{article}
#       \pagestyle{empty}
#       \begin{document}
#
#       \begin{displaymath}
#       \bf  % Compiled formulae often look better in boldface
#       \int H(x,x')\psi(x')dx' = -\frac{\hbar^2}{2m}\frac{d^2}{dx^2}
#                                 \psi(x)+V(x)\psi(x)
#       \end{displaymath}
#
#       \end{document}
#
#   The "\pagestyle{empty}" is required to avoid generating a huge
#   image with a page number at the bottom.
#
#   Then (assuming you have all the software described below installed
#   properly), you can simply say:
#
#       textogif [-dpi nnn] [-res nnn] filename ...
#
#   to compile filename.tex to filename.gif, an interlaced,
#   transparent background GIF file ready to use an an inline image.
#   You can specify the base name, for example, "schrod", rather than
#   the full name of the TeX file ("schrod.tex").  TeX requires the
#   input file to have an extension of ".tex".  The command line
#   options, "-dpi" and "-res" are described below under "Default
#   Configuration".
#
#   A sample IMG tag, including the image width and height is printed
#   on standard error, for example:
#
#       <img src="schrod.gif" width=508 height=56>
#
#                         Required Software
#
#   This script requires the following software to be installed
#   in the standard manner.  Version numbers are those used in the
#   development and testing of the script.
#
#   Perl        4.0 Patch level 36
#   TeX         3.141 (C version d)
#   LaTeX2e     patch level 3
#   dvips       dvipsk 5.521a
#   Ghostscript 2.6.1 (5/28/93)
#   pstoppm.ps  (version supplied with Ghostscript 2.6.1)
#   Netpbm      1 March 1994
#
#   Ghostscript's library search must be configured so it can
#   find pstoppm.ps (or you'll have to copy pstoppm.ps into your
#   working directory).
#
#                       Default Configuration
#
#   The following settings are the defaults used if the -dpi and
#   -res options are not specified on the command line.
#
#   The parameter $dpi controls how large the equation will appear
#   with respect to other inline images and the surrounding text.
#   The parameter is expressed in "dots per inch" in the PostScript
#   sense.  Unfortunately, since there's no standard text size in
#   Web browsers (and most allow the user to change fonts and
#   point sizes), there's no "right" value for this setting.  The
#   default of 150 seems about right for most documents.  A setting
#   of 75 generates equations at half the normal size, while 300
#   doubles the size of equations.  The setting of $dpi can always be
#   overridden by specifying the "-dpi" command line option.
#
    $dpi = 150;
#
#   The parameter $res specifies the oversampling as the ratio
#   of the final image size to the initial black and white image.
#   Smaller values produce smoothing with more levels of grey but
#   require (much) more memory and intermediate file space to create
#   the image.  If you run out of memory or disc space with the
#   default value of 0.5, try changing it to 0.75.  A $res setting of
#   1.0 disables antialiasing entirely.  The setting of $res can
#   always be overridden by specifying the "res" command line option.
#
    $res = 0.5;
#
#   If no path or input files are specified, we bail out right away:
#
	if ($#ARGV < 2) {
		print "Need to specify path and input TeX file.";
		exit 1;
	}
#
#   Command line option processing
#
$PATH;
$OUTFILE;
$FILE_NAME;             # to make $f global to use later on

    while ($ARGV[0] =~ m/^-/) {
        $_ = shift(@ARGV);
        if (m/^-d/) {                 # -dpi nnn
            $dpi = shift(@ARGV);
        } elsif (m/^-r/) {            # -res nnn
            $res = shift(@ARGV);
        } elsif (m/^-o/) {            # -out outputFile
	    $OUTFILE = shift(@ARGV);
	} elsif (m/^-p/) {	      # -path filePath
	    $PATH = shift(@ARGV);
	}
    }
#
#   Main file processing loop
#

    foreach $f (@ARGV) {
        $f =~ s/(.*)\.tex$/$1/;
        system("echo x | latex " . $PATH . "/" . $f . "\n") == 0 ||
            die("LaTeX error processing $PATH/$f.tex\n");
#	unlink ("$f.tex");
	unlink ("$f.log");
	unlink ("$f.aux");
        system("dvips -f $f >$f.ps\n") == 0 ||
#       system("dvips -f $f >_temp_$$.ps\n") == 0 ||  # use PID
            die("DVIPS error processing $f.dvi\n");
	unlink ("$f.dvi");
	$FILE_NAME = $f;
    }


##############################################################################
# The rest of what John Walker would have us do just wasn't working, so      #
# the rest of this script is an adaptation of Nikos Dragos's pstogif script. #
##############################################################################
# 
# pstogif.pl v1.0, July 1994, by Nikos Drakos <nikos@cbl.leeds.ac.uk>
# Computer Based Learning Unit, University of Leeds.
#
# Accompanies LaTeX2HTML Version 96.1
#
# Script to convert an arbitrary PostScript image to a cropped GIF image
# suitable for incorporation into HTML documents as inlined images to be
# viewed with WWW browsers.
#
# This is based on the pstoepsi script 
# by Doug Crabill dgc@cs.purdue.edu
#
# Please note the following:
# - The source PostScript file must end
#   in a .ps extention.  This is a GhostScript requirement, not mine...
# - The -density argument has no effect unless the 
#   color depth (set with the -depth argument) is equal to 1.
# - Valid arguments for -depth are 1,8, or 24.
#  
# This software is provided as is without any guarantee.
#
# Nikos Drakos (ND), nikos@cbl.leeds.ac.uk
# Computer Based Learning Unit, University of Leeds.
#
# 15 Jan 96 HS Call ppmquant only if needed.  Fixed bug relative to
#    V 95.3 .
#
# 15 Dec 95 HS (Herbert Swan <dprhws.edp.Arco.com> Added support for
#    the flip=option.  This allows images to be oriented differently
#    in the paper versus the electronic media
#
# 1 Nov 95 jmn - modified for use with gs ppm driver - from jhrg's patches
#    note that ppmtops.ps and ppmtops3.ps are no longer needed
#
# 20 JUL 94 ND Converted to Perl and made several changes eg it now accepts 
#    parameters from environment variables or from command line or will use 
#    default ones. 
#      
# 1  APR 94 ND Changed the suffixes of multi-page files from xbm to gif (oops!)
#
# 
#####################################################################
#
#$| =1;
#&read_args;

### You may need to specify some pathnames here if you want to
### run the script without LaTeX2HTML

# Ghostscript
$GS= $ENV{'GS'} || 'gs';

# Comes with LaTeX2HTML (For ghostscript versions greater than 3.0 
# you need the newer pstoppm.ps)
#$PSTOPPM= $ENV{'PSTOPPM'} ||
#    'pstoppm.ps';

# Available in the PBMPLUS libary	   
$PNMCROP=$ENV{'PNMCROP'} || 'pnmcrop' ;

# Also in PBMPLUS
$PNMFLIP=$ENV{'PNMFLIP'} || 'pnmflip' ;

# Also in PBMPPLUS	  
$PPMTOGIF=$ENV{'PPMTOGIF'} || 'ppmtogif' ;

# Also in PBMPPLUS	  
$REDUCE_COLOR=$ENV{'PPMQUANT'} || 'ppmquant 256' ;
 
$GIFTRANS = 'giftrans' ;

#$OUTFILE = $ENV{'OUTFILE'} || $out;
			
# Valid choices for $COLOR_DEPTH are 1, 8 or 24. 
$DEPTH = $ENV{'DEPTH'} || $depth || 24;

#Default density is 72
$DENSITY = $ENV{'DENSITY'} || $density || 72;
    
# Valid choices are any numbers greater than zero
# Useful choices are numbers between 0.1 - 5
# Large numbers may generate very large intermediate files
# and will take longer to process
$SCALE = $ENV{'SCALE'} || $scale; # No default value

$PAPERSIZE = $ENV{'PAPERSIZE'} || $papersize; # No default value;

$DEBUG = $ENV{'DEBUG'} || $DEBUG || 0;

######################################################################

&main;

#sub read_args {
#    local($_);
#    local($color);
#    while ($ARGV[0] =~ /^-/) {
#	$_ = shift @ARGV;
#	if (/^-h(elp)?$/) {
#	    &usage; exit}
#       elsif (/^-out$/) {
#            $out = shift @ARGV;
#	}
#	elsif (/^-(.*)$/) {
#	    eval "\$$1 = shift \@ARGV"; # Create and set a flag $<name>
#	    }
#    }
#}		 

sub main {
    local($outfile, $i, $j);
    &test_args;
    $outfile = $OUTFILE || "$FILE_NAME.gif";
    open(STDERR, ">/dev/null") unless $DEBUG;
    &convert;
    if (-f "$FILE_NAME.ppm") {
	&crop_scale_etc("$FILE_NAME.ppm", $outfile);
    }
    else {
	foreach $i (<$FILE_NAME.[1-9]*ppm>) {
	$j = $i; 
	$j =~ s/\.(.*)ppm/$1.gif/;
	&crop_scale_etc($i, $j)}
    }				
    &make_transparent($outfile);
    &cleanup($FILE_NAME);
}

sub make_transparent {
    local($out) = @_;
    print "Making $PATH/$out transparent with call 'giftrans -t#ffffff $PATH/$out > $PATH/${out}_trans'\n";
    system("giftrans -t#ffffff $PATH/$out > $PATH/${out}_trans");
    rename("$PATH/${out}_trans", "$PATH/$out");
}

sub crop_scale_etc {
    local($in, $out) = @_;
    local($tmp) = $in . ".tmp";
    open(STDERR, ">/dev/null") unless $DEBUG;

    if ($flip) {
	rename($tmp, $in) unless system("$PNMFLIP -$flip $in > $tmp");
    }
    system("$PNMCROP $in > $tmp");

    if (system("$PPMTOGIF $tmp > $PATH/$out")) {
	print "Running ppmquant for $out\n";
	system("$REDUCE_COLOR < $tmp|$PPMTOGIF - > $PATH/$out");
    }
    unlink $tmp;
    unlink ("$FILE_NAME.ps"); 
    print "Writing $out\n";
}

sub test_args {
    if (! ($DEPTH =~ /^(1|8|24)$/)) {
	print "The color depth must be 1 or 8 or 24. You specified $DEPTH\n";
	exit 1
    }
    if (defined $SCALE) {
	if ($SCALE > 0) {
	    $DENSITY = int($SCALE * $DENSITY)}
	else {
	    print "Error: The scale must be greater than 0.\n" .
		"You specified $SCALE\n";
	    exit 1
	}
    }
}
   
sub convert {
    local($paperopt) = "-sPAPERSIZE=$PAPERSIZE" if $PAPERSIZE;
    local($ppmtype) = join('', "ppm",$DEPTH,"run");
    local($density) = "-r$DENSITY" if ($DENSITY != 72);
    open (GS, "|$GS -q -dNOPAUSE -dNO_PAUSE -sDEVICE=ppmraw $density -sOutputFile=$FILE_NAME.ppm $paperopt $FILE_NAME.ps");
    close GS;
}

sub cleanup {
    local($FILE_NAME) = @_;
    unlink <$FILE_NAME[0-9.]*ppm>;
}

#sub usage {
#    print "Usage: pstogif [-h(elp)] [-out <output file>] [-depth <color depth 1, 8 or 24>]  [-flip #<Flip_code>] [-density <pixel density>] <file>.ps\n\n";
#}





