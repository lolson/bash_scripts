package Configuration;

use strict;
use DBI;

# This class manages the configuration for all of the validation classes.
# It maintains a hash of key value properties, and any arbitrary property
# can be returned from the getProperty method, but the configuration properties
# that we are familiar with have shortcut methods to simplify the access.

# The name of the properties we expect to find/have shortcut methods to.
our $VERBOSE = 'verbose';
our $SHOWSQL = 'show_sql';
our $MODE = 'mode';
our $DBDDRIVER = 'dbd_driver';
our $EDUSOFT_DB_HOST = 'edusoft.db.host';
our $EDUSOFT_DB_NAME = 'edusoft.db.name';
our $DATA_DB_HOST = 'data.db.host';
our $DATA_DB_TABLE = 'data.db.table';
our $DATA_DB_NAME = 'data.db.name';
our $SERIES_ID = 'series_id';
our $EVENT_ID  = 'event_id';
our $DISTRICT_ID = 'district_id';
our $ROSTER_ID = 'roster_id';
our $DELIMITER = 'delimiter';

# This is the constructor for the configuration class.  It takes a config
# file as a paramter, which is expected to be in standart properties format:
# name = value.  
sub init {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $configFile = shift;
  my $self = {};
  
  initializeDefaults($self);
  
  open(CONFIG, $configFile) or die "Could not open config file: $configFile: $!";
  while(<CONFIG>) {
    # skip commented out lines and blank lines
    next if (/^#/ || /^\s*$/);
    if (/=/) {
      # get the name and value
      (my $name, my $value) = split('\s*=\s*', $_, 2);
      # trim white space
      $name =~ s/^\s+//;
      $value =~ s/\s+$//;
      $$self{$name} = $value;
    } else {
      print "WARNING: invalid line in config file: $_";
    }
  }
  close(CONFIG);
  
  bless ($self, $class);
  return $self;
}

# initializes some properties to default values, so they are not
# required in the config file
sub initializeDefaults {
  my $self = shift;
  
  # default is not verbose
  $$self{$VERBOSE} = 0;
  # default is don't show sql
  $$self{$SHOWSQL} = 0;
  # default mode is fixed (this should probably refer to a shared var)
  $$self{$MODE} = 1;
  # default delimiter is a tab
  $$self{$DELIMITER} = "\t";  
  # default dbd is Pg
  $$self{$DBDDRIVER} = "Pg";
}

# can return any property specified in the configuration file.
sub getProperty {
  my $self = shift;
  my $propName = shift;
  my $value = $$self{$propName};
  unless(defined($value)) {
    die "required property $propName not defined\n";
  }
  return $value;
}

# returns a edusoft db handle for this configuration
sub edusoftDB {
  my $self = shift;
  my $dbh = DBI->connect
  ("dbi:".$self->dbdDriver.":dbname=".$self->edusoftDBName().
   ";host=".$self->edusoftDBHost(),
   "edusoft",
   "edusoft") 
  or die $DBI::errstr;  
  return $dbh;
}

# returns a data db handle for this configuration
sub dataDB {
  my $self = shift;
  my $dbh = DBI->connect
  ("dbi:".$self->dbdDriver.":dbname=".$self->dataDBName().
   ";host=".$self->dataDBHost(),
   "edusoft",
   "edusoft") 
  or die $DBI::errstr;  
  return $dbh;
}

# a bunch of shortcut methods to make accessing the properties easier
sub verbose {
  my $self = shift;
  return $self->getProperty($VERBOSE);
}

sub showSQL {
  my $self = shift;
  return $self->getProperty($SHOWSQL);
}

sub edusoftDBName {
  my $self = shift;
  return $self->getProperty($EDUSOFT_DB_NAME);
}

sub edusoftDBHost {
  my $self = shift;
  return $self->getProperty($EDUSOFT_DB_HOST);
}

sub dataDBName {
  my $self = shift;
  return $self->getProperty($DATA_DB_NAME);
}

sub dataDBHost {
  my $self = shift;
  return $self->getProperty($DATA_DB_HOST);
}

sub dataDBTable {
  my $self = shift;
  return $self->getProperty($DATA_DB_TABLE);
}

sub seriesID {
  my $self = shift;
  return $self->getProperty($SERIES_ID);
}

sub eventID {
  my $self = shift;
  return $self->getProperty($EVENT_ID);
}

sub districtID {
  my $self = shift;
  return $self->getProperty($DISTRICT_ID);
}

sub rosterID {
  my $self = shift;
  return $self->getProperty($ROSTER_ID);
}

sub mode {
  my $self = shift;
  return $self->getProperty($MODE);
}

sub dbdDriver {
  my $self = shift;
  return $self->getProperty($DBDDRIVER);
}

sub delimiter {
  my $self = shift;
  return $self->getProperty($DELIMITER);
}
1;
