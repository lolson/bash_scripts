use strict;
use DBI;
use Configuration;

# constants
my $FIXED = 1;
my $DELIMITED = 2;
my $NAME = 'name';
my $START = 'start';
my $END = 'end';
my $PATTERN = 'pattern';
my $REPLACE = 'replace';
my $TOKEN = 'token';
my $TYPE = 'type';
my $INTTYPE = 'I';
my $FLOATTYPE = 'F';
my $STRTYPE = 'S';

my $DEFAULTSIZE = 50;


my $configFile = shift(@ARGV);
my $formatFile = shift(@ARGV);
my $dataFile = shift(@ARGV);

# initialize the configuration
my $config = Configuration->init($configFile);

my $dbh = $config->dataDB();

# the program operates in two modes
my $mode = $config->mode();

# used to define the delimiter for delimited file, default is a comma
my $delimiter = $config->delimiter();

# turn off buffered output
$| = 1;

# a list of all the columns defined in this file
my @columns = populateList($formatFile);
createTable($config->dataDBTable(), \@columns);
insertData($config->dataDBTable, $dataFile, \@columns);

$dbh->disconnect;

# Actually inserts the data into the database.  It creates
# an appropriate INSERT statement, and then executes that
# INSERT statement for each line of the file.
sub insertData {
  my $tableName = shift;
  my $dataFile = shift;
  my $colRef = shift;
  
  # keep track of the number of columns
  my $colCount = 0;
  my $insert = "INSERT INTO $tableName (";  
  # creates the list of column names
  foreach my $col (@$colRef) {
    $insert .= "$$col{$NAME} ,";
    $colCount++;
  }
  # get rid of the last comma
  chop $insert;
  $insert .= ") VALUES (";
  # adds a place holder for each column
  $insert .= " ? ," x $colCount;
  # get rid of the last comma, again
  chop $insert;
  $insert .= ")";
  
  my $insertStatement = $dbh->prepare($insert);
  print "insert statement: $insert\n";
  $dbh->begin_work;
  open(DATA, $dataFile) or die "could not open data file: $dataFile";
  
  my $line = 0;
  LINE: while(<DATA>) {
    # remove new line chars
    s/\r?\n$//;
    $line++;

    # only used for delimited files
    my @tokens = split($delimiter);

    # this is the list of values from the file, in the same order they 
    # are specified in $colRef.
    my @values;    
    
    foreach my $col (@$colRef) {
      my $value;
      if ($mode == $DELIMITED) {
        $value = $tokens[$$col{$TOKEN} - 1];
      } elsif ($mode == $FIXED) {
        my $length = $$col{$END} - $$col{$START} + 1;
        $value = substr($_, $$col{$START}, $length);
      }
      
      my $pattern = $$col{$PATTERN};            
      if (defined($pattern)) {
        if ($value =~ /${pattern}/) {
          # if we didn't match the pattern, don't bother trying
          # to execute the replacement
          my $replace = $$col{$REPLACE};
          if (defined($replace)) {
            $value =~ s/${pattern}/${replace}/ee;
          }
        } else {
          # This allows the value to be inserted even if it doesn't
          # match, and just writes this warning.  Because the replacement
          # only happens if there's a match on the regex, it isn't clear what
          # should happen if a value doesn't match, we may want to throw this
          # line completely away, or we may want to do what we're doing here,
          # and insert the data that can be inserted.
          #
          # We have decided to throw this line away.  skip to the next line if
          # it doesn't match.
          
          print "Warning: '$value' does not match specified " . 
                "pattern '$pattern' at line $line, line not loaded \n";
          next LINE;
        }
      }
      
      
      if (($$col{$TYPE} eq $INTTYPE or $$col{$TYPE} eq $FLOATTYPE)) {
        # if it's a numeric type, and it's all whitespace, change it to
        # undef, so it will be inserted as NULL in the DB.
        if ($value =~ /^\s*$/) {
          $value = undef;
        } elsif ((!$value =~ /^[\d.]+/)) {
          # if there is data, make sure it's numeric stuff, otherwise warn
          # currently a really simple check, could use a better regex here
          print "\tERROR: $$col{$NAME} is a numeric field, and ".
                " '$value' is set as a value, line not loaded\n";
          next LINE;
                    
        }
      }
      
      # if it's a string type, trim it
      if ($$col{$TYPE} eq $STRTYPE) {
        $value =~ s/^\s+//;
        $value =~ s/\s+$//;
      }
      push (@values, $value);
    }
    
    unless($insertStatement->execute(@values)) {
      $dbh->rollback;
      die "Could not insert row for line: $_, " . $insertStatement->errstr;
    }
  }
  $dbh->commit;
  $insertStatement->finish;
}

# Takes a table name, and a refrence to a list column structures 
# as parameters.  Creates a table in the named database with one
# column for each column in the list.  All string columns are VARCHARs. 
# For fixed width files, those VARCHARs are the same size as the
# as the fields defined in the file.  For delimited files we use
# $DEFAULTSIZE.  Integer fields become bigints, and float fields
# become NUMERIC(8,2) fields.

sub createTable {
  my $tableName = shift;  
  my $colRef = shift;

  # Drop the table, this will likely cause errors, as this
  # table will often not exist.
  my $dropSQL = "DROP TABLE $tableName";   
  
  my $dropStatement = $dbh->prepare($dropSQL);  
  # just try and execute it, if there's an error, print a warning.
  $dropStatement->execute or
    print "Warning: could not delete table: " . $dropStatement->errstr . "\n";
  $dropStatement->finish;
  
  my $createSQL;
  $createSQL .= "CREATE TABLE $tableName (";
  
  foreach my $col (@$colRef) {
    my $colName = $$col{$NAME};
    my $size;
    
    if ($STRTYPE eq $$col{$TYPE}) {
      if ($mode == $FIXED) {
        $size = $$col{$END} - $$col{$START} + 1;
      } elsif ($mode == $DELIMITED) {
        $size = $DEFAULTSIZE;
      }
      $createSQL .= "$colName \tVARCHAR($size),";
    } elsif ($FLOATTYPE eq $$col{$TYPE}) {
      # Consider all floats to be NUMERIC(8,2), which 
      # is what we use as the score type in the DB.  
      $createSQL .= "$colName \tNUMERIC(8,2),";
    } elsif ($INTTYPE eq $$col{$TYPE}) {
      $createSQL .= "$colName \tBIGINT,";
    }
    
  }
  
  #get rid of the extra ,
  chop $createSQL;
  $createSQL.= ")";
  print "Table Creation: $createSQL";
  
  my $createQuery = $dbh->prepare($createSQL);
  $createQuery->execute() or 
    die "Could not create table for import: " . $createQuery->errstr;
  $createQuery->finish;
}

# This method takes a format file, and creates an list of
# hashes that define an individual column represented in
# the format file.  Each column contains a column name,
# something to indicate its location (either a token number,
# or a start and end postion, depending on the mode), and 
# my contain a pattern to match against, and a replacement
# pattern.

sub populateList {
  my $formatFile = shift;
  open(FORMAT, $formatFile) or die "Can't open $formatFile : $!";

  while(<FORMAT>) {
     # remove new line chars
     s/\r?\n$//;  
     my $name;
     my $type;
     my $location;
     my $pattern;
     my $replace;
     
     # skip comments and blank lines
     next if (/^#/ or /^\s*$/);
     
     # fields are comma delimited
     ($name, $type, $location, $pattern, $replace) = split("\t");
     
     my %column = ($NAME => $name);
     $column{$TYPE} = $type;
     if (defined($pattern)) {
       $column{$PATTERN} = $pattern;
       if (defined($replace)) {
         $column{$REPLACE} = $replace;
       }
     }
     
     if ($mode == $FIXED) {
       # The start and end positions are colon delimited
       # for a fixed width file
       my $start;
       my $finish;
       ($start, $finish) = split(":", $location);
       # files are usually 1 based, so make the format
       # 1 based also store one less as start and finish
       # so we can use normal 0 base in function calls
       $column{$START} = $start - 1;
       $column{$END} = $finish - 1;
     } elsif ($mode == $DELIMITED) {
       $column{$TOKEN} = $location;
     }
     push @columns, \%column;

  }
  close(FORMAT);
  return @columns;  
}