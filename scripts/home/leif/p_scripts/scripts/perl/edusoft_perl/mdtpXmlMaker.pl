#!/usr/bin/perl -w
#
# author: Ed Koster
# description: Converts an MDTP text-file skeleton into an MDTP xml file
#              ready for importing with com.edusoft.app.admin.mdtp.MDTPImporter
#              The text file should be of the following format (without the
#              hash marks or my comments):
# Geometry Readiness Test 1994         // test name. description on next line. 
# 2006-2007           // administration
# This is a diagnostic test of topics needed for success in a geometry course.
# 1356                // covered standard
# 4                   // num choices per question
# 1     C     POLQ    // q1 with answer and topic, tab-delimited
# 2     C     INGL    // same for q2
# ...
# 45    B     GRPH
#                     // blank line
# GRPH  4     Graphical Representation   // topic, mastery-level, description
# EXPS  3     Exponents and Square Roots; Scientific Notation    // CG 1

# ...

($#ARGV >= 0) || die "Usage: mdtpXmlMaker.pl file";

# open specified text file
$arg = shift;
(-f $arg) || die "Could not find or open ${arg}.";
($arg =~ /\w+.txt/) || die "${arg} does not end with extension .txt";
open (IN, $arg);

# create output xml file (specified filename with ".xml" ending)
$arg =~ s/(\w+\.)txt/${1}xml/g;
open (OUT, ">$arg");

# write out xml header
print OUT "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print OUT "<edusoft_content>\n";
print OUT "<assessment aligned=\"TRUE\">\n";

# first 4 lines are the test name, description, covered standard,
# and number of choices per question.
$name = <IN>;
chomp $name;
$administration = <IN>;
chomp $administration;
$description = <IN>;
chomp $description;
$standard = <IN>;
chomp $standard;
$num_choices = <IN>;
chomp $num_choices;
print OUT "<administration>${administration}</administration>\n";
print OUT "<header description=\"${description}\">\n";
print OUT "<title>${name}</title>\n";

# stick everything in the same section
print OUT "</header>\n<section sequence=\"1\">\n\n";

while($line = <IN>) {
    chomp $line;
# put questions into question sets
    if ($line =~ /^(\d+)\t(\D)\t([\w ,-]+)\s?$/) {
        print OUT "<question_set>\n";
        print OUT "<question type=\"MULTIPLE_CHOICE\" source_key=\"MDTP\" sequence=\"${1}\" standard_universal_id=\"${standard}\" points=\"1\" custom_groups=\"${3}\">\n";
        print OUT "<question_content>\n";
        print OUT "<body />\n";
        # write out the possible answers
        for ($sequence = 1; $sequence <= $num_choices; $sequence++) {
            $label = chr(ord('a') + $sequence - 1);
            print OUT "<answer sequence=\"${sequence}\" label=\"${label}\"";
            if ($label eq lc($2)) {
                print OUT " correct=\"TRUE\"";
            }
            print OUT "><body /></answer>\n";
        }

        print OUT "</question_content>\n";
        print OUT "</question>\n";
        print OUT "</question_set>\n\n";

# when we hit a blank line, we're done
    } elsif ($line =~ /\s*/) {
        print OUT "</section>\n</assessment>\n";  # end section and assessment
        last; # break out and proceed to custom groups
    }
# any other format is unacceptable
    else {
        die "The question line \"${line}\" is not in any proper format.\n" .
            "Please make sure that it is of the format:\n" .
            "<question number><tab><correct answer><tab><topic abbreviation>" .
            "\nIf this is a topic line, please make sure you left a blank " .
            "line between the questions and the topics.";
    }
}

# start custom groups
print OUT "<custom_groups>\n";

# put groups into custom groups
while ($line = <IN>) {
    chomp $line;
    if ($line =~ /^([\w ,-]+)\t(\d+)\t(.+)$/) {
        print OUT "<custom_group name=\"${1}\" mastery=\"${2}\" description=\"${3}\" />\n";
    }
    else {
        die "The topic line \"${line}\" is not in any proper format.\n" . 
            "Please make sure that it is of the format:\n" .
            "<topic abbreviation><tab><mastery level><tab><topic description>";
    }
}

# end custom groups and xml footer
print OUT "</custom_groups>\n";
print OUT "</edusoft_content>\n";

# close out the files
close OUT;
close IN;



