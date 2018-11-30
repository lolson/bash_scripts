use strict;
use DBI;

use Validator;
use Template;
use Configuration;

my $configFile = shift(@ARGV);
my @templateFiles = @ARGV;

# read configuration data
my $config = Configuration->init($configFile);

# a handle to the "data" database, the database the data file was loaded into
my $dataHandle = $config->dataDB();
 
# a handle to the database that's we're validating the assigns for.
my $assignHandle = $config->edusoftDB();

# initialize the templates.
my $template = Template->parseTemplates(\@templateFiles);

# turn off buffered output
$| = 1;

studentLoop($config, $template, \&checkAssign, $dataHandle, $assignHandle);
$dataHandle->disconnect;
$assignHandle->disconnect;


sub checkAssign {
  my $config = shift;
  my $template = shift;
  my $firstName = shift;
  my $lastName = shift;
  my $id = shift;
  my $dataHandle = shift;
  my $edusoftHandle = shift;
  
  # first lookup the ethnicity, and find the school for the student.
  my $schoolID = checkEthnicityAndLookupSchoolID($config, 
                                                 $template, 
                                                 $firstName, 
                                                 $lastName, 
                                                 $id, 
                                                 $dataHandle, 
                                                 $edusoftHandle);
  # if we couldn't find a schoolID, consider this student to have failed
  # and move to the next line                                               
  return unless($schoolID);                                                 
  if ($config->verbose) {
    print "\tschoolID: $schoolID \n";
  }
                   
  # now check the ed programs                 
  checkEdPrograms($config, 
                  $template, 
                  $firstName, 
                  $lastName, 
                  $id, 
                  $schoolID,
                  $dataHandle, 
                  $edusoftHandle);                 
}

# as it name implies, this method checks the ethnicty, and looks up the 
# students school id.  Like all of the other validation tools, this 
# method is unhappy if it find multiple schools for any user.  It queries
# the student_school_roster table to find the user's ethnicity, and while
# it's there, it pulls back the school ID, so we can use it later in the
# ed program query.    
sub checkEthnicityAndLookupSchoolID {
  my $config = shift;
  my $template = shift;
  my $first = shift;
  my $last = shift;
  my $id = shift;
  my $dataHandle = shift;
  my $edusoftHandle = shift;
  
  my $schoolSQL = "SELECT school_id, ethnicity.name ".
                  "FROM users, user_student_info usi, ".
                  "student_school_roster ssr, ethnicity " .
                  "WHERE lower(users.first_name) = '$first' " .
                  "AND lower(users.last_name) = '$last' " .
                  "AND users.district_id = '".$config->districtID."' ".
                  "AND usi.school_student_code = '$id' " .
                  "AND ssr.student_user_id = users.user_id " .
                  "AND ssr.roster_id = '".$config->rosterID."' ".
                  "AND usi.student_user_id = users.user_id " .
                  "AND ssr.ethnicity_id = ethnicity.ethnicity_id " .                  
                  "AND ssr.deleted_ind IS FALSE ".                  
                  "AND users.deleted_ind IS FALSE" ;  
  my $schoolID = 0;
  my $eduEthnicity;
  
  my $schoolQuery = $edusoftHandle->prepare($schoolSQL);
     
  $schoolQuery->execute 
     or die "Could not calculate lookup school id for user: " . 
            $schoolQuery->errstr;

  # if we find more than one student/school combination for a given
  # first/last/id combination, return an error
  my @resultRow = 
    executeSingleResultQuery(
      $schoolQuery, 
      "\tERROR: could not find school id for: $first $last, $id\n",
      "\tERROR: $first$last, $id Matched multiple entries in could".
      " not locate schoolID\n");
  if (@resultRow) {
    ($schoolID, $eduEthnicity) = @resultRow;
    if ($config->verbose) {
      print "\tLoaded ethnicity: $eduEthnicity \n";
    }  
  }
  $schoolQuery->finish;                  
  
  my $ethnicity = $template->ethnicity;
  
  # if an ethnicity is defined in the template, verify it,
  # otherwise, skip this check
  if (defined($ethnicity)) {
    my $calc = $$ethnicity{$Template::CALC};
    my $dataSQL = createDataQuery($config, $calc, $first, $last, $id);
    if ($config->showSQL) {
      print "\tData Query: $dataSQL \n";
    }
    my $dataQuery = $dataHandle->prepare($dataSQL);
    $dataQuery->execute 
      or die "Could not calculate score data from data file: " . 
             $dataQuery->errstr;
    my @dataRow = 
      executeSingleResultQuery(
        $dataQuery, 
        "\tERROR: Could caculate ethnicity from data for $first $last, $id\n",
        "\tERROR: $first $last, $ID Matched multiple entries in " . 
  	    "the data file, can not compare\n");
    if (@dataRow) {
      my $ethnicityData = $dataRow[0];
      my $mappedEthnicity = $template->getSingleMappedValue(
        $ethnicity, 
        $ethnicityData, 
        "\tERROR: No ethnicities defined in the data file\n",
        "\tERROR: Multiple ethnicities defined in map/data files, ".
          "only one ethnicity supported\n");
      unless(defined($mappedEthnicity)) {
        return;
      }
      
      unless ($mappedEthnicity eq $eduEthnicity) {
        print "\tWARNING: Data file defines ethnicity as $mappedEthnicity, " .
              "but it\'s stored in the DB as $eduEthnicity \n";
      } else {
        if ($config->verbose) {
          print "\tEthnicity matched\n";
        }
      }      
    } else {
      return 0;
    }     
  	$dataQuery->finish;                   
  }
  return $schoolID;
}

# this method checks all of the enrolled ed programs.  It first queries for all
# of the ed programs that the student is enrolled in in the edusoft db.  It 
# then queries for all the ed programs specified in the data file.  It reports
# any programs that are defined in one and not the other.

sub checkEdPrograms {
  my $config = shift;
  my $template = shift;
  my $firstName = shift;
  my $lastName = shift;
  my $id = shift;
  my $schoolID = shift;
  my $dataHandle = shift;
  my $edusoftHandle = shift;
  
 # get all of the ed programs the user is enrolled in for the given roster
 my $epSQL = "SELECT ed_program.name ".
             "FROM users, user_student_info usi, ed_program, ".
             "ed_program_school_roster epsr, user_group_map ugm ".
             "WHERE lower(users.first_name) = \'".$firstName."\' " .
             "AND lower(users.last_name) = \'".$lastName."\' " .
             "AND users.district_id = \'".$config->districtID."\' " .
             "AND usi.school_student_code = \'".$id."\' " . 
             "AND usi.student_user_id = users.user_id " .
             "AND ed_program.ed_program_id = epsr.ed_program_id ".
             "AND ".$config->rosterID."= epsr.roster_id ".
             "AND ugm.user_id = users.user_id ".
             "AND ugm.group_id = epsr.ed_program_school_roster_id ".
             "AND ugm.deleted_ind is FALSE ".
             "AND users.deleted_ind IS FALSE";
  my $epQuery = $edusoftHandle->prepare($epSQL);
  if ($config->showSQL) {
    print "\ted_program query: $epSQL \n";
  }
  $epQuery->execute 
     or die "Could not lookup school id for user: " . $epQuery->errstr;
  my $dataRows = $epQuery->fetchall_arrayref;  
  # this is a hash of the ed_programs the student is enrolled in.
  my %edPrograms = map({$$_[0], 1} @$dataRows);
  $epQuery->finish;                         
  
  # create select string for the data query  
  my $selectString;
  foreach my $edProgram (@{$template->edPrograms}) {
    $selectString .= " ".$$edProgram{$Template::CALC}.",";
  }
  # get rid of the extra ,
  chop $selectString;
  my $dataSQL =  
    createDataQuery($config, $selectString, $firstName, $lastName, $id);
  if ($config->showSQL) {
    print "\tdata query: $dataSQL \n";  
  }
  my $dataQuery = $dataHandle->prepare($dataSQL);
  

  $dataQuery->execute 
    or die "Could not find ed program data from data file: " . 
           $dataQuery->errstr;
       
  my @epData = 
    executeSingleResultQuery(
      $dataQuery, 
      "\tERROR: Could caculate ed programs from data ".
      "for $firstName $lastName, $id $\n",
      "\tERROR: $firstName $lastName, $id Matched multiple entries in " . 
	  "the data file, can not compare\n");
  if (@epData) {
    my $cnt = 0;
    foreach my $ep (@epData) {
      foreach my $value (
        @{$template->getMappedValues(${$template->edPrograms}[$cnt], $ep)}) {
        
        # if the ed_program is one of the programs they are enolled in in the
        # edusoft db, delete it from the list of ed_programs.  Otherwise, 
        # report that this student is not enrolled in the specified ed program.
        # NOTE: this routine expects that a student will only be mapped to a 
        #       given ed program by one entry in the template file.  If they
        #       are entered more than once, we will report an error here, 
        #       because it will have been removed the first time it was seen.
        if ($value and exists($edPrograms{$value})) {
#          delete($edPrograms{$value});
          $edPrograms{$value} = 0;
        } else {
          # only print an error if the value is more than just whitespace
          if (!($value =~ /^\s*$/)) {
            print "\tWARNING: data file enrolls student in $value and ".
                  "the student is not enrolled in that Ed Program\n";
          }
        }        
      }
      $cnt++;
    }  
  } else {
    return 0;
  }
  $dataQuery->finish;   
  
  # Any ed programs still in the hash are ed programs that weren't mapped by
  # the data file; report them.
  foreach my $program (keys %edPrograms) {
    if ($edPrograms{$program} == 1) {
          print "\tWARNING: student enrolled in $program but ".
                "was not enrolled from the data file\n";  
    }
  }
}