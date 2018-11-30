#!/usr/bin/perl


##############
# SUBROUTINES
##############


# return file handle
# argument: table name
sub getOutputFile
{
    my $tableName = shift(@_);
    
    local *FILEHANDLE;
    my $found = 0;
    
    # see if we already have an output file for the table
    for($i = 0; $i < scalar(@tables); $i++) {
        if($tableName eq $tables[$i]) {
            *FILEHANDLE = $outputs[$i];
            $found = 1;
        }
    }
    
    if($found == 0) {
        $outputFilename = $batchFilesDir.$tableName.".copy";
        open FILEHANDLE, ">$outputFilename";
        @tables = (@tables, $tableName);
        @outputs = (@outputs, *FILEHANDLE);
    }
    
    return *FILEHANDLE;
}


###############
# MAIN PROGRAM
###############


# parses a file of INSERT and UPDATE statements and creates a set of
# corresponding files that have the inserts converted to a batch file ready
# for a COPY FROM

# corresponding arrays of table names and the output files corresponding to them
@tables = ();
@outputs = ();

$input = shift;           # the file to read from
$batchFilesDir = shift;

# make sure file path ends with path separator
$lastSlash = rindex($batchFilesDir, "/");
$lastBackslash = rindex($batchFilesDir, "\\");
$lastIndex = length($batchFilesDir) - 1;
if(!($lastSlash == $lastIndex || $lastBackslash == $lastIndex))
{
    $batchFilesDir = $batchFilesDir."/";
}

if(!defined($input) || !defined($batchFilesDir)) {
    print "\nUsage: batchInsertParser <inputFile> <outputDir>\n";
    print "    <inputFile>   is the file holding the SQL INSERT statements\n";
    print "    <outputDir>   is where the import files will be written\n";
    print "                  it MUST be absolute and end with /\n\n";
    exit 1;
}

#print "Reading from '$input'\n";
#print "Writing to '$batchFilesDir'\n";

# open file to write updates to
open UPDATE, ">".$batchFilesDir."updates.sql";

# run through all of the lines in the input file
open IN, $input;
while($line = <IN>) {
#    print $line;
    
    # if it is an update line, send it to the update file
    if($line =~ /^UPDATE/) {
        print UPDATE $line;
    }
    else {
        # remove newline at end
        chop($line);
        
        # get the table name
        ($insert, $into, $tableName, $junk) = split(/[\ ]+/, $line, 4);
        
        # find the correct output file
        $out = &getOutputFile($tableName);
        
        # get the values for output
        ($before, $after) = split(/VALUES/, $line, 2);
#        print "after: '$after'\n";
        
        $firstParen = index($after, "(");
        $lastParen = rindex($after, ")");
#        print "$firstParen $lastParen\n";
        
        $valueStr = substr($after, $firstParen+1, $lastParen-$firstParen-1);
#        print "valueStr: '$valueStr'\n";
        
        @values = split(/[\ ]*,[\ ]*/, $valueStr);
        $numValues = @values;
#        print "numValues = $numValues\n";
        
        # print the values to the output file
        for($i = 0; $i < $numValues; $i++) {
            $value = $values[$i];
#            print "'$value'\n";
            
#  this is a more complex if statement that might be overkill
#            if($value !~ /\'\'/ &&
#               (($value =~ /^\'/ && $value !~ /\'$/) ||
#                ($value =~ /^\'/ && $value =~ /\'\'$/))) {
            
#  this is a simpler while statement 
            while($value =~ /^\'/ && $value !~ /\'$/) {
#                print "$value";
                $i++;
                $value = $value.", ".$values[$i];
#                print " ---> $value\n";
            }
            
            $value =~ s/^[\s]*//;     # delete whitespace at front
            $value =~ s/[\s]*$//;     # delete whitespace at end
            $value =~ s/^\'//;        # delete ' at front
            $value =~ s/\'$//;        # delete ' at end
            $value =~ s/\'\'/\'/g;    # change '' to ' anywhere in $value
            print $out "$value";
            if($i < $numValues-1) {
                print $out "|";
            }
        }
        # we have to use the newline character that is compatible with COPY
        print $out "\n";
    }
}

# close our output streams

close IN;
close UPDATE;

# close all the output files
foreach $output (@outputs) {
    close $output;
}

# create a .sql file with just the COPY statements
open OUT, ">".$batchFilesDir."copy.sql";
foreach $table (@tables) {
    print OUT "COPY $table FROM '$batchFilesDir$table.copy' USING DELIMITERS '|' WITH NULL AS 'null';\n";
    print OUT "VACUUM ANALYZE $table;\n";
}
close OUT;

# create the shell file to run
open OUT, ">".$batchFilesDir."importData.sh";
print OUT "#!/bin/sh\n\n";
print OUT "psql -a -d edusoft -f '".$batchFilesDir."copy.sql'\n";
print OUT "psql -a -d edusoft -f '".$batchFilesDir."updates.sql'\n";
close OUT;
