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
 
# a handle to the database that's we're validating the scores for.
my $scoreHandle = $config->edusoftDB();

# initialize the templates.
my $template = Template->parseTemplates(\@templateFiles);

# turn off buffered output
$| = 1;

# check the scores
studentLoop($config, $template, \&scoreCheckFunc, $dataHandle, $scoreHandle);
$dataHandle->disconnect;
$scoreHandle->disconnect;

# Calculates any scores that are defined in the template file(s), and looks 
# those scores up in DB to see if the scores match.  This method can take a 
# long time to run, it executes one query against the edusoft db for each 
# category we're checking the scores for, and one for each score line in the 
# template file.


sub scoreCheckFunc {
  my $config = shift;
  my $template = shift;
  my $firstName = shift;
  my $lastName = shift;
  my $id = shift;
  my $dataHandle = shift;
  my $edusoftHandle = shift;
  
  
  # for each student, verify each of their scores.  Look
  # at all the defined scores for a particular category before
  # moving to the next category
  foreach my $cat (keys %{$template->scores}) {
    print "\tcategory:$cat \n";
    my %columns = %{${$template->scores}{$cat}};
    # find all the scores for this category in the db.
    # we may not need all five scores, but it's really no more 
    # expensive to just grab them all, and it makes building this
    # query easier to read.                
    my $scoreSQL = "SELECT score_1, score_2, score_3, score_4, score_5 " . 
                   "FROM scores, users, " . 
                   "user_student_info usi, category, series " .
                   "WHERE scores.category_id = category.category_id " .
                   "AND category.category_key = '$cat' " .
                   "AND category.category_tree_id = " . 
                   "    series.category_tree_id " .
                   "AND series.series_id = '".$config->seriesID."' " .                       
                   "AND scores.event_id = '".$config->eventID."' " .
                   "AND lower(users.first_name) = '$firstName' " .
                   "AND lower(users.last_name) = '$lastName' " .
                   "AND users.district_id = '".$config->districtID."' " .
                   "AND usi.school_student_code = '$id' " . 
                   "AND usi.student_user_id = users.user_id " .
                   "AND scores.student_user_id = users.user_id " .
                   "AND scores.deleted_ind IS FALSE " .
                   "AND series.deleted_ind IS FALSE " .
                   "AND users.deleted_ind IS FALSE" ;                       
    if ($config->showSQL) {
      print "\t\tlooking up scores using: $scoreSQL \n";
    }                           
    my $scoreQuery = $edusoftHandle->prepare($scoreSQL);    
    $scoreQuery->execute 
      or die "Could not retrieve score data: " . $scoreQuery->errstr;                 
  	
  	my @dbScores;

   	my $scoreRows = $scoreQuery->fetchall_arrayref;     	
  	if (scalar(@$scoreRows) == 0) {
  	  # if there's no score in the DB, set dbScore to null, so we can see
  	  # if it matches the null score we'll have stored in the data table.
      @dbScores = ();
      # As above, we assume that we're only going to find one score row
  	} elsif (scalar (@$scoreRows) > 1) {
  	  print "\t\tERROR: Found multipe score for $firstName $lastName, $ID in " . 
  	        "the database, can not compare\n";
  	  next;    	
  	} else {
  	  # save the scores that we found.
  	  @dbScores = @{$$scoreRows[0]};
  	}         
    $scoreQuery->finish; 
      
    
    # now look up each score we're checking
    # this could probably be made into one query also.
    foreach my $col (keys %columns) {
      if ($config->verbose) {
        print "\t\tcolumn $col \n";
      }
      
      my $calculation = ${$columns{$col}}{$Template::CALC};
      my $dataSQL = 
        createDataQuery($config, $calculation, $firstName, $lastName, $id);
      if ($config->showSQL) {
        print "\t\t\tcalculating score using:$dataSQL \n";
      }
      my $dataQuery = $dataHandle->prepare($dataSQL);

      my $calculatedScore;
      $dataQuery->execute 
        or die "Could not calculate score data from data file: " . 
               $dataQuery->errstr;
               
      my $dataRows = $dataQuery->fetchall_arrayref;
      # this shouldn't happen, since we're looking up the student IDs from data 
   	  # we just got from this db.
  	  if (scalar(@$dataRows) == 0) {
  	    print "\t\tERROR: Could caculate score from data for $firstName $lastName, $ID\n";
  	    next;
      # if a student's not unique, we don't know how to compare the scores
  	  } elsif (scalar (@$dataRows) > 1) {
  	    print "\t\tERROR: $firstName $lastName, $ID Matched multiple entries in " . 
  	          "the data file, can not compare\n";
  	    next;    	
  	  # store the score we found
  	  } else {
  	    ($calculatedScore) = @{$$dataRows[0]};
  	  }
  	  $dataQuery->finish;
  	  
  	  if (defined($calculatedScore)) {
        my $mappedData = $template->getSingleMappedValue(
          \%{$columns{$col}},
          $calculatedScore, 
          "ERROR: There is no mapping defined for $calculatedScore \n",
          "ERROR: Student scores can only be mapped to a single Value, ".
          "$calculatedScore maps to multiple\n");  
          
        unless(defined($mappedData)) {
          return;
        }        
        $calculatedScore = $mappedData;
  	  }
  	  
      # if both scores are undefined, or they are equal, we found
      # what we wanted
      if ((!defined($calculatedScore) && (!(@dbScores) || 
           !defined($dbScores[$col - 1]))) ||         
          $dbScores[$col - 1] == $calculatedScore) {
        
        if ($config->verbose) {
          if (!defined($calculatedScore)) {
            print "\t\t\t data matches, no scores defined\n";
          } else {
            print "\t\t\tscore $calculatedScore matched\n";
          }
        }
      } else {
        print "\t\tWARNING:score: $col for category: $cat did not match for " . 
              "$firstName $lastName, $id, cacluated $calculatedScore " .
              "and db contains $dbScores[$col - 1]\n"
      }
    }
  }
}
