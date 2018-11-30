#!/usr/bin/perl -w
#
# author: Ginger Ellsworth (modification of mdtpXmlMaker.pl by Ed Koster)
# description: Converts an assessment-format text-file skeleton into an assessment xml file
#              ready for importing with (TODO: ginger fill in)
#              The text file should be of the following format (without the
#              hash marks or my comments):
#
# notes:
#   - no num answer choices for non MC questions
#   - no correct answer for non MC questions
#   - all MC questions will have answer labels starting with "A" (eg A/B/C/D if num answer choices = 4)
#   - universal IDs and course titles should be comma delimited if there is more than 1
#   - a new section will be started when question type changes from one question to the next, so group questions
#         of the same question type.
#   - questions with differing point values and num answer choices *can* be in the same section.
#
# Geometry Readiness Test 1994         // test name
# Administration Name                  // administration
# This is a diagnostic test of topics needed for success in a geometry course.
# Algebra 1A1, Algebra 1A2                // courses aligned to this test (blank if none)
# // all question fields should be tab delimited
# // qsequence, qtype (MC/SA/LA), points, universal IDS, qmeta data, num answer choices, correct answer. 
# 1     MC    1   1693, 1689   ETS.1.3.45B   4   D
# 2     MC    2   1690         ETS.1.3.55B   3   A
# 3     MC    1   1694, 1699   ETS.1.3.65C   4   C
# 4     LA    5   1594, 1708   ETS.1.3.75C  
# ... etc ...


# ...

($#ARGV >= 1) || die "Usage: assessmentXmlMaker.pl file source_type \n" .
                     " e.g.  assessmentXMLMaker.pl la_grade_6.txt ETS"; 

# open specified text file
$arg = shift;
(-f $arg) || die "Could not find or open ${arg}.";
($arg =~ /\w+.txt/) || die "${arg} does not end with extension .txt";
open (IN, $arg);

# get question source type into a variable;
$source_type = shift;

# create output xml file (specified filename with ".xml" ending)
$arg =~ s/(\w+\.)txt/${1}xml/g;
open (OUT, ">$arg");

# write out xml header
#print OUT "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print OUT "<edusoft_content>\n";
print OUT "<assessment aligned=\"TRUE\">\n";

# first 4 lines are the test name, administration, 
# description, covered standard,
# and number of choices per question.
$name = <IN>;
chomp $name;
$administration = <IN>;
chomp $administration;
$description = <IN>;
chomp $description;
$courses = <IN>;
chomp $courses;
print OUT "<header description=\"${description}\">\n";
print OUT "<title>${name}</title>\n";
print OUT "<administration>${administration}</administration>\n";
print OUT "<courses>${courses}</courses>\n";

# start the first section - we will change the section when the qtype changes
$sectionSequence = 1;
print OUT "</header>";

$current_question_type = 'nothing';
while($line = <IN>) {
    chomp $line;

    if ($line =~ /^(\d+)\t(\w+)\t(\d+)\t([\d\,\s]+)\t([\w\-\.]+)\t(\d)\t(\w)\s?$/) {	
	$qtype = 'MC';
        if ($2 eq $qtype) {
	    $qtype =  "MULTIPLE_CHOICE";
	} else {
	    die "The question line \"${line}\" is in multiple choice format " .
		"but doesn't have \"MC\" as the qtype";	    
	}
	if ($current_question_type ne $qtype) {
	    if ($current_question_type ne "nothing") {
		print OUT "</section>";
	    }
	    $current_question_type = $qtype;
	    print OUT "\n<section sequence=\"${sectionSequence}\">\n\n";
	    $sectionSequence++;
	}

	print OUT "<question_set>\n";
	print OUT "<question ";
	print OUT "source_type=\"${source_type}\" sequence=\"${1}\" standard_universal_id=\"${4}\" ";
	print OUT "points=\"${3}\" type = \"${qtype}\">\n";
	print OUT "<question_content>\n";
	print OUT "<body />\n";
	# write out the possible answers
	for ($sequence = 1; $sequence <= $6; $sequence++) {
	    $label = chr(ord('a') + $sequence - 1);
	    print OUT "<answer sequence=\"${sequence}\" label=\"${label}\"";
	    if ($label eq lc($7)) {
		print OUT " correct=\"TRUE\"";
	    }
	    print OUT "><body /></answer>\n";
	}
	
	print OUT "</question_content>\n";

	print OUT "<question_meta_data>";
	print OUT "<ets_id>${5}</ets_id>";
	print OUT "</question_meta_data>";

	print OUT "</question>\n";
	print OUT "</question_set>\n\n";

    } elsif ($line =~ /^(\d+)\t(\w+)\t(\d+)\t([\d\,\s]+)\t([\w-]+)\s?$/) {	
	$qtype = 'LA';
        if ($2 eq $qtype) {
	    $qtype = "LONG_ANSWER";
	} else {
	    die "The question line \"${line}\" is in long answer format " .
		"but doesn't have \"LA\" as the qtype";	    
	}	
	if ($current_question_type ne $qtype) {
	    if ($current_question_type ne "nothing") {
		print OUT "</section>";
	    }
	    $current_question_type = $qtype;
	    print OUT "\n<section sequence=\"${sectionSequence}\">\n\n";
	    $sectionSequence++;
	}

	print OUT "<question_set>\n";
	print OUT "<question ";
	print OUT "source_type=\"${source_type}\" sequence=\"${1}\" ";
	print OUT "standard_universal_id=\"${4}\" ";
	print OUT "points=\"${3}\" type = \"${qtype}\"";	
	print OUT " meta-data=\"${5}\">\n";
	print OUT "<question_content>\n";
	print OUT "<body />\n";
	print OUT "</question_content>\n";

	print OUT "<question_meta_data>";
	print OUT "<ets_id>${5}</ets_id>";
	print OUT "</question_meta_data>";

	print OUT "</question>\n";
	print OUT "</question_set>\n\n";

# when we hit a blank line, we're done
    } elsif ($line =~ /^\s*$/) {
	last; # break
    }
# any other format is unacceptable
    else {
	die "The question line \"${line}\" is not in any proper format.\n" .
	    "Please correct it.\n";
    }
}

print OUT "</section>\n</assessment>\n";  # end last section and assessment
print OUT "</edusoft_content>\n";

# close out the files
close OUT;
close IN;



