package Validator;

use strict;
use warnings;

# Module stores shared methods that are used by the various validators

BEGIN {
  use Exporter   ();
  our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
  
  # set the version for version checking
  $VERSION     = 1.00;
  @ISA         = qw(Exporter);
  @EXPORT      = qw(&executeSingleResultQuery &studentLoop &createDataQuery $FIRSTNAME $LASTNAME $ID $MIDDLENAME $GENDER $DOB $SSN);
  @EXPORT_OK   = ( );  
  %EXPORT_TAGS = ( );   

}

# required field constants
# these fields must be in the template file, or there's no way
# to identify students
our $FIRSTNAME = 'first_name';
our $LASTNAME = 'last_name';

# NOTE: we operate under the assumption that the IDs are always put
# in school_student_code.  This is true now, but something to watch
# for changes.
our $ID = 'school_student_code';

our $MIDDLENAME = 'middle_name';
our $DOB = 'dob';
our $GENDER = 'gender';
our $SSN = 'ssn';
our $SCHOOL_NAME = 'school_name';
# This function is used as a general framework for all of the validators that
# use the template format.  It forms a query that filters out students based
# on the template filters.  It then loops over the result set, for each result
# it calls the specified function.
#
# parameters
# $config - a configuration object
# $template - a template object
# $func - the function that should be executed.  
#         This method is passed these parameters:
#           $config - the config object passed to this method
#           $template - the template object passed to this method
#           $firstName - the firstname of the student we're analyzing
#           $lastName - the lastname of the student we're analyzing
#           $id - the id of the student we're analyzing
#           $dataHandle - the data handle passed to this method
#           $edusoftHandle - the edusoft handlepassed to this method
# $dataHandle - a handle to the "data" database
# $edusoftHabdle - a handle to the edusoft database

sub studentLoop {
  my $config = shift;
  my $template = shift;
  my $func = shift;
  my $dataHandle = shift;
  my $edusoftHandle = shift;
  
  my $whereClause;
  if (defined($template)) {
    $whereClause = $template->createWhereClause;
  } else {
    $whereClause = "";
  }  
  
  # query used to get all matching students
  my $studentSQL = "SELECT lower($FIRSTNAME), lower($LASTNAME), $ID " .  
                     "FROM ".$config->dataDBTable." $whereClause";
  
  if ($config->showSQL) {
    print "student data query: $studentSQL \n";
  }
                     
  my $studentQuery = $dataHandle->prepare($studentSQL);
  $studentQuery->execute 
    or die "Could not query students: " . $studentQuery->errstr;
  
  # loop over the list of students, and verify all of their data
  while(my @studentInfo = $studentQuery->fetchrow_array) {
    (my $firstName, my $lastName, my $id) = @studentInfo;
    print "checking data for $firstName $lastName, $id \n";  
    &{$func}($config, $template, $firstName, $lastName, 
             $id, $dataHandle, $edusoftHandle);   
  }
  $studentQuery->finish;
}

sub createDataQuery {
  my $config = shift;
  my $select = shift;
  my $first = shift;
  my $last = shift;
  my $id = shift;
  my $dataSQL = "SELECT $select FROM ".$config->dataDBTable." ".
                "WHERE lower($FIRSTNAME) = '$first' " .
                "AND lower($LASTNAME) = '$last' " .
                "AND $ID = '$id'";          
  return $dataSQL;
}

# for an executed query goes through the steps we continually go through in
# validation.  Prints an error if there is no result, prints an error if there
# are multiple results, execute some method if there is exactly one result.  The
# return value of this function is () if in an error condition, otherwise it's the
# list columns for the single row

sub executeSingleResultQuery {
  my $query = shift;
  my $noneError = shift;
  my $multipleError = shift;
  
  my $dataRows = $query->fetchall_arrayref;
  if (scalar(@$dataRows) == 0) {
    print $noneError;
    return ();
  } elsif (scalar (@$dataRows) > 1) {
    print $multipleError;
    return ();
  } else {
    return @{$$dataRows[0]};    
  }
}

END {}

1;
