use strict;

use DBI;
use XML::Parser;
use Configuration;


# This program checks a structure file against the database to ensure
# that all data has been imported properly.  The program dies at any
# error; it assumes that an error found early in the processing of the
# document can cause problem validating the later parts of the file.

# set when we are reading the administartion definitions
my $definingAdmins = 0;

# when parsing the category tree, keeps track of the current depth
my $depth = 0;

# The category tree id for the series corresponding to the structure file
my $categoryTreeID;

# The series ID for this ile
my $seriesID;

# used to keeps track of the category stack for category structure validation
my @categoryHierarchy;

# Used when looking up assessments to ensure they are properly defined
my $currentEventID;

# configuration file
my $configFile = $ARGV[0];

# the file containing the structure
my $filename = $ARGV[1];

# initialize the configuration, which will be used
# throughout the program.
my $config = Configuration->init($configFile);

# handle to the edusoft database instance to validate against
my $dbh = $config->edusoftDB;
 
my $categoryQuery = $dbh->prepare("SELECT category_id, parent_id, name ".
                                  "FROM category " .
                                  "WHERE category_tree_id = ? AND " .
                                  "category_key = ?");   	

# handle to a parser for the xml file
my $parser = new XML::Parser(Style => 'Subs');

# turn off buffered output
$| = 1;

# kick of the program
$parser->parsefile($filename);

$dbh->disconnect;


###################################################
# Parser Subroutines                              #
###################################################

# called when administrations are being defined.  
# This method should only be called one time for a 
# structure file.
sub administrations {
    if ($config->verbose) {
      print "Looking up administration definitions\n";
    }
    $definingAdmins = 1;
}

sub administrations_ {
    if ($config->verbose) {
      print "Finished looking up administration definitions\n";
    }
    $definingAdmins = 0;
}

# <series> is the root node of a structure file,
# this method is called when the parsing of the file
# starts.  This is where we verify that the series
# has been created, and we retrieve the category tree id
# which is used later for category validation.
sub series {
    my $expat = shift;
    my $elem = shift;
  	my %keys = @_;  	    	
  	
  	my $seriesTitle = $keys{'title'};
  	
  	if ($config->verbose) {
  	  print "looking up series: $seriesTitle \n";
  	}
  	
  	# we search for a series by its title
  	
  	my $seriesQuery = $dbh->prepare("SELECT category_tree_id, series_id " .
  	                                "FROM series WHERE title = ? " .
  	                                "AND shared_ind IS TRUE " .
  	                                "AND deleted_ind IS false");
  	                                
  	if ($seriesQuery->execute($seriesTitle)) {
  	  
  	  my $rows = $seriesQuery->fetchall_arrayref;
  	  if (scalar(@$rows) == 0) {
  	    print "Could not find a query with title: $seriesTitle";
  	  } elsif (scalar(@$rows) > 1) {
  	    print "Series title: $seriesTitle is not unique\n";
  	  } else {
  	    ($categoryTreeID, $seriesID) = @{$$rows[0]};
  	    if ($config->verbose) {
  	      print "\tFound series. \n\tcategory_tree_id = $categoryTreeID" .
  	            "\n\tseries_id = $seriesID \n";
  	    }
  	  }
  	} else {
  	   die "Could not query the database: " . $seriesQuery->errstr;
  	}
  	
  	$seriesQuery->finish;
}

sub administration {
    if ($definingAdmins) {
  	  my $expat = shift;
	  my $elem = shift;	  
	  my %keys = @_;
	  
	  my $term = $keys{'term'};
	  my $year = $keys{'year'};
	  my $title = $keys{'title'};
	  my $key = $keys{'key'};
	  my $rosterID;
	  
      if ($config->verbose) {
        print "\tFinding roster: $term, for year: $year\n";
      }

      # find a roster term by its year and term_title

      my $termQuery = $dbh->prepare("SELECT roster_id FROM roster_term " .
                                    "WHERE year = ? AND term_title = ?");
      if ($termQuery->execute($year, $term)) {
     	  my $rows = $termQuery->fetchall_arrayref;
     	  if (scalar(@$rows) == 0) {
     	    die "ERROR: Could not find a term with title: $term";
     	  } elsif (scalar(@$rows) > 1) {
     	    die "ERROR: Found multiple terms with title: $term for year $year";
     	  } else {
     	    ($rosterID) = @{$$rows[0]};
     	    if ($config->verbose) {
     	      print "\tFound roster\n\troster_id = $rosterID \n";
     	    }
     	  }	      
      } else {
        die "Could not query the database: " . $termQuery->errstr;
      }
      $termQuery->finish;
	    	
	  # find an event by its key, year, roster_id, and series id
      # the key field is stored in the file_handle field in the DB,
      # as documented in the SQL files that create the tables
      my $adminQuery = $dbh->prepare("SELECT event_id, name FROM event " .
	                                 "WHERE file_handle = ? AND year = ?" .
	                                 "AND roster_id = ? AND series_id = ?" .
    	                             "AND deleted_ind IS false");	                                 
      if ($config->verbose) {
        print "\tFinding event for key: $key, for year: $year, " . 
              "roster: $rosterID \n";
      }	   

      if ($adminQuery->execute($key, $year, $rosterID, $seriesID)) {
     	  my $rows = $adminQuery->fetchall_arrayref;
     	  if (scalar(@$rows) == 0) {
     	    die "Could not an event with key: $key and year: $year";
     	  } elsif (scalar(@$rows) > 1) {
     	    die "Found multiple events with key: $key for year $year";
     	  } else {
     	    my $name;
     	    ($currentEventID, $name) = @{$$rows[0]};
     	    if (!($name eq $title)) {
     	      print "\t\tWARNING: event name in DB is $name, " . 
     	            "name in file is: $title\n";
     	    }
            if ($config->verbose) {
              print "\t\tFound event\n\t\ttitle = $title ". 
                    "\n\t\tevent_id = $currentEventID\n";
            }	        	    
     	  }	      
      } else {
        die;
      }
      $adminQuery->finish;
    }
}

# looks up an assessment, by its sequence number.  Warns
# if the names don't match.  Once a test is found/validated,
# it tries to find an entry in test/event for this test,
# and the current event we're validating.
sub assessment {
    if ($definingAdmins) {
	  my $expat = shift;
	  my $elem = shift;
	  my %keys = @_;

	  my $title = $keys{'title'};
	  my $sequence = $keys{'seq'};
	  
      my $testQuery = $dbh->prepare("SELECT test_id, test_type_id, title " . 
                                    "FROM test WHERE sequence = ? " . 
                                    "AND series_id = ? " . 
                                    "AND deleted_ind IS false");
      if ($config->verbose) {
        print "\t\tFinding Test for sequence: $sequence , " . 
              "and event: $currentEventID \n";
      }	   

      my $testID;
      	                                 
      if ($testQuery->execute($sequence, $seriesID)) {
     	  my $rows = $testQuery->fetchall_arrayref;
     	  if (scalar(@$rows) == 0) {
     	    die "Could not a testwith title: $title";
     	  } elsif (scalar(@$rows) > 1) {
     	    die "Found multiple tests with title: $title";
     	  } else {
            my $testTypeID;
            my $name;
     	    ($testID, $testTypeID, $name) = @{$$rows[0]};
     	    if (!($name eq $title)) {
     	      print "\t\t\tWARNING: test name in DB for sequence: $sequence " . 
     	            "is $name, name in file is: $title\n";
     	    }     	    
     	    if ($config->verbose) {
       	      print "\t\t\tFound Test\n\t\t\ttitle = $title" . 
       	            "\n\t\t\ttest_id = $testID" . 
       	            "\n\t\t\ttest_type = $testTypeID\n";
     	    }
     	    if ($testTypeID != 1) {
     	      die "test sequence $sequence has an invalid " . 
     	          "test type: $testTypeID";
     	    }
     	  }	      
      } else {
        die;
      }
      $testQuery->finish;

      # ensure there is a test event for this combination.
      # there can be only one, the database is unique on these
      # fields
      my $testEventQuery = $dbh->prepare("SELECT 1 FROM test_event WHERE " .
                                         "test_id = ? " . 
                                         "AND event_id = ? " . 
                                         "AND series_id = ?");
      if ($config->verbose) {
        print "\t\t\tFinding Test Event for series: $seriesID, " . 
              "event: $currentEventID, test: $testID\n";
      }	   
      if ($testEventQuery->execute($testID, $currentEventID, $seriesID)) {
     	  my $rows = $testEventQuery->fetchall_arrayref;
     	  if (scalar(@$rows) == 0) {
     	    die "Could not a test_event";
     	  } else {
     	    if ($config->verbose) {
     	      print "\t\t\t\tFound test event\n";
     	    }
     	  }
      }
    }
}

sub category {
    my $expat = shift;
    my $elem = shift;
    my %keys = @_;
    
    my $catKey = $keys{'key'};
    my $title = $keys{'title'};

   if ($config->verbose) {
     print "\t" x $depth . "Looking for category with key: $catKey \n";
   }
     
    my $catID;
    my $parentID;
    if ($categoryQuery->execute($categoryTreeID, $catKey)) {
      my $rows = $categoryQuery->fetchall_arrayref;
  	  if (scalar(@$rows) == 0) {
  	    die "Could not find a category with key: $catKey";
  	  } elsif (scalar(@$rows) > 1) {
  	    die "Category key: $catKey is not unique";
  	  } else {
  	    my $name;
  	    ($catID, $parentID, $name) = @{$$rows[0]};
  	    # store this category on the stack
  	    $categoryHierarchy[$depth] = $catID;  	      	    
  	    if ($depth > 0) {
  	      if ($categoryHierarchy[$depth - 1] != $parentID) {
  	        die "Invalid category hierarchy.  " . 
  	            "Expected parent category to be " .
  	            "$categoryHierarchy[$depth - 1], and found $parentID \n";
  	      }
  	    } else {
          if (defined($parentID)) {
            die "top level category has a parent id: $parentID\n"; 
          }
  	    }
  	    if (!($title eq $name)) {
  	      print "WARNING: expected to find $title as name for ". 
  	            "category: $catKey, and found $name\n";
  	    }
  	    if ($config->verbose) {
  	      print "\t" x ($depth + 1) . "Found category $name. \n" . 
  	            "\t" x ($depth + 1) . "cat_id = $catID\n";
  	    }
   	  }      
    } else {
      die "couldn't execute category query";
    } 
    $depth++;
    $categoryQuery->finish;    
}

sub category_ {
    $depth--;
}

