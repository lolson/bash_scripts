use strict;
use DBI;

use Validator;
use Configuration;
use Template;


# This tool verifies student information in the DB (only data that can
# be found in the users and user_student_info table).  It searches for
# a student based on first_name, last_name, and school_student_code, and
# then checks specified fields to ensure they loaded properly

# supported student info types.
my $DOB = "dob";
my $SSN = "ssn";
my $MIDDLE_NAME = "middle_name";
my $GENDER = "gender";

my $configFile = shift(@ARGV);
my @templateFiles = @ARGV;

# read configuration data
my $config = Configuration->init($configFile);

# a handle to the "data" database, the database the data file was loaded into
my $dataHandle = $config->dataDB();
 
# a handle to the database that's we're validating the scores for.
my $scoreHandle = $config->edusoftDB();

# init the templates
my $template = Template->parseTemplates(\@templateFiles);

my $selectString = createSelectString($template);


# turn off buffered output
$| = 1;

# initialize the templates.
studentLoop($config, $template, \&validateStudent, $dataHandle, $scoreHandle);
$dataHandle->disconnect;
$scoreHandle->disconnect;


sub validateStudent {
  my $config = shift;
  my $template = shift;
  my $firstName = shift;
  my $lastName = shift;
  my $id = shift;
  my $dataHandle = shift;
  my $edusoftHandle = shift;
  
  my @dataValues;
  my @edusoftValues;
  
  # find the student info in the edudb
  my $studentSQL = "SELECT middle_name, gender, dob, ssn " . 
                   "FROM users, user_student_info usi " .
                   "WHERE lower(users.first_name) = '$firstName' " .
                   "AND lower(users.last_name) = '$lastName' " .
                   "AND users.district_id = '".$config->districtID."' " .
                   "AND usi.school_student_code = '$id' " . 
                   "AND usi.student_user_id = users.user_id " .
                   "AND users.deleted_ind IS FALSE" ;
                   
  if ($config->showSQL) {
    print "\tLooking up loaded student info using: $studentSQL \n";
  }    
  
  if ($config->showSQL) {
    print "\tdata sql: "
      .createDataQuery($config, $selectString, $firstName, $lastName, $id)
      ."\n";
  }
  
  my $dataQuery = $dataHandle->prepare(
    createDataQuery($config, $selectString, $firstName, $lastName, $id));
  my $studentQuery = $edusoftHandle->prepare($studentSQL);
  
  $dataQuery->execute 
     or die "Could not calculate student data from data file: " . 
            $dataQuery->errstr;
  @dataValues = 
    executeSingleResultQuery(
      $dataQuery, 
      "\tERROR: could not find user in edusoft DB\n",
      "\tERROR: Found multipe score for $firstName $lastName, $ID in " . 
      "the database, can not compare\n");
  # if we had an error before, move on to the next student.
  unless (@dataValues) {
    return;
  }            

  $dataQuery->finish;
  
  $studentQuery->execute 
    or die "Could not retrieve score data: " . $studentQuery->errstr;                 
    
  @edusoftValues = 
    executeSingleResultQuery(
      $studentQuery, 
      "\tERROR: could not find user in edusoft DB\n",
      "\tERROR: Found multipe score for $firstName $lastName, $ID in " . 
      "the database, can not compare\n");
  # if we had an error before, move on to the next student.
  unless (@edusoftValues) {
    return;
  }

  $studentQuery->finish; 

  # check middle_name
  checkValues($template, $dataValues[0], $edusoftValues[0], $MIDDLE_NAME);
  # check gender
  checkValues($template, $dataValues[1], $edusoftValues[1], $GENDER);
  # check dob
  checkValues($template, $dataValues[2], $edusoftValues[2], $DOB);  
  # check ssn
  checkValues($template, $dataValues[3], $edusoftValues[3], $SSN);  
}

# creates the select string.  Inserts a 1 for any field that
# isn't defined, so the select string can be in the same order
# as the query from the db.
sub createSelectString {
  my $template = shift;
  my $select = "";
  if (defined(${$template->studentInfo}{$MIDDLE_NAME})) {
    my %studentCmd = %{${$template->studentInfo}{$MIDDLE_NAME}};
    $select .= " ".$studentCmd{$Template::CALC}.",";    
  } else {
    $select .= "1,";
  }
  
  if (defined(${$template->studentInfo}{$GENDER})) {
    my %studentCmd = %{${$template->studentInfo}{$GENDER}};
    $select .= " ".$studentCmd{$Template::CALC}.",";      
  } else {
    $select .= "1,";
  }      
  
  if (defined(${$template->studentInfo}{$DOB})) {
    my %studentCmd = %{${$template->studentInfo}{$DOB}};
    $select .= " ".$studentCmd{$Template::CALC}.",";      
  } else {
    $select .= "1,";
  }    
  
  
  if (defined(${$template->studentInfo}{$SSN})) {
    my %studentCmd = %{${$template->studentInfo}{$SSN}};
    $select .= " ".$studentCmd{$Template::CALC}.",";      
  } else {
    $select .= "1,";    
  }
      
  chop $select;
  return $select;
}

# check the values.  $val1 is the value that came from the data db, $val2 is 
# the value from the edusoft database, and $name is a name to print in the 
# program's output.  
sub checkValues() {
  my $template = shift;
  my $dataVal = shift;
  my $edusoftVal = shift;
  my $name = shift;
  
  # if it's a 1, skip it, that's just a fill in value for the data
  if ($dataVal eq "1") {
    return;
  }
  
  my $cmd = \%{${$template->studentInfo}{$name}};
  my $mappedData = $template->getSingleMappedValue(
    $cmd, 
    $dataVal, 
    "ERROR: There is no mapping defined for $dataVal \n",
    "ERROR: Student data can only be mapped to a single Value, $dataVal ".
    "maps to multiple\n");  
    
  unless(defined($mappedData)) {
    return;
  }
  
  if ($mappedData eq $edusoftVal) { 
    if ($config->verbose) {
      print "\t$name matched\n";
    }
  } else {
    print "\tWARNING: $name does not match: ".
          "data file contains, or was mapped to $mappedData, ".
          "loaded data contains $edusoftVal \n"; 
  }       
}