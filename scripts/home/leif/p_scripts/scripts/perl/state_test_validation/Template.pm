package Template;
use strict;

# command constants
our $ED_PROGRAM = 'ed_program';
our $ETHNICITY = 'ethnicity';
our $FILTER = 'filter';
our $MAP = 'map';
our $SCORE = 'score';
our $STUDENT_INFO = 'student_info';

# record constants
our $NAME = 'name';
our $VALUE = 'value';
our $CALC = 'calc';
our $MAPNAME = 'map_name';

# This method takes an array of files, and parses them as template files.
# A template file defines filters, maps, scores, ed_programs and ethnicity
# definitions.  The files are parsed in the order they are passed in, with
# later definitions overwriting earlier definitions for map, score, 
# ed_program and ethnicity information


sub parseTemplates {
  # class initialization
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = {};
  
  bless($self, $class);

  my $files = shift;

  my @filters;
  my %maps;
  my %scores;
  my @edPrograms;
  my @ethnicities;
  my %studentInfo;
  
  foreach my $file (@$files) {
    open(TEMPLATE, $file);
    while(<TEMPLATE>) {
      # remove new line chars
      s/\r?\n$//;      
      # skip comment lines and blank lines
      next if (/^#/ or /^\s*$/);
        
      my $command;
      my $args;
      unless(/:/) {
        print "Warning: No command specified on line: $_ \n";
      }
      ($command, $args) = split(":", $_, 2);
      
      # strip white space around command
      $command =~ s/\s*(\w+)\s*/$1/;
      
      # check for ed_program lines and ethnicity lines, and just skip
      # them, since the same file may be used for score templates and
      # assign templates.
      if ($command eq ${ED_PROGRAM} || $command eq ${ETHNICITY}) {
        (my $calc, my $map) = split (",", $args);
        
        strip(\$calc);
        
        my %assign = ($CALC => $calc);
        if (defined($map)) {
          strip(\$map);
          $assign{$MAPNAME} = $map;
        }        
        
        if ($command eq ${ED_PROGRAM}) {
          push (@edPrograms, \%assign);
        } else {
          if (scalar(@ethnicities) > 0) {
            die "ERROR: multiple ethnicities are defined in the template file; " .
                "only primary ethnicity verification is supported\n";
          }
          push (@ethnicities, \%assign);
        }
      } elsif ($command eq ${FILTER}) {
        (my $name, my $value) = split(",");
        strip (\$name, \$value);
        my %filter = ($NAME => $name, $VALUE => $value);
        push (@filters, \%filter);
      } elsif ($command eq ${SCORE}) {
        (my $category, my $column, my $calc, my $map) = split(",", $args);
        strip(\$category, \$column, \$calc);

        if ($column !~ /^[1-5]$/) {
          die "invalid score column: $column \n";
        }
        my %score = ($CALC => $calc);
        if (defined($map)) {
          strip(\$map);
          $score{$MAPNAME} = $map;
        }
        ${$scores{$category}}{$column} = \%score;
        
      } elsif ($command eq ${MAP}) {        
        (my $name, my $orig, my $replace) = split (",", $args);
        strip(\$name, \$orig, \$replace);
        push(@{${$maps{$name}}{$orig}}, $replace);
      } elsif ($command eq ${STUDENT_INFO}) {
        (my $data_type, my $calc, my $map) = split(",", $args);
        strip(\$data_type, \$calc);
        my %info = ($CALC => $calc);
        if (defined($map)) {
          strip(\$map);
          $info{$MAPNAME} = $map;
        }
        $studentInfo{$data_type} = \%info;        
      } else {
        print "Warning: unknown command in template file: $_ \n";
      }
    }
    close(TEMPLATE);
  }
  
  $$self{$FILTER} = \@filters;
  $$self{$SCORE} = \%scores;
  $$self{$MAP} = \%maps;
  $$self{$ED_PROGRAM} = \@edPrograms;
  $$self{$ETHNICITY} = \@ethnicities;
  $$self{$STUDENT_INFO} = \%studentInfo;  
  return $self;
}

sub getSingleMappedValue {
  my $self = shift;
  my $command = shift;
  my $value = shift;
  my $noneError = shift;
  my $multipleError = shift;
  
  my @values = $self->getMappedValues($command, $value);
  if(!scalar(@values)) {
    print $noneError;
    return undef;
  } elsif (scalar(@values) > 1) {
    print $multipleError;
    return undef;
  } else {
    return ${$values[0]}[0];
  } 
}

# This method will lookup mapped values in the defined maps
# given the map name, and the value to map. 

sub getMappedValues {
  my $self = shift;
  my $command = shift;
  my $value = shift;
  
  my $name = $$command{$Template::MAPNAME};  	    
  return [$value] unless (defined($name));
  
  my %mapSet = %{$self->maps};
  unless (defined($mapSet{$name})) {
    print "WARNING: no map $name defined, value not mapped \n";
    return [$value];
  }
  unless (defined($value)) {
    $value = '';
  }
  my $mappedValue = ${$mapSet{$name}}{$value};
  if (defined($mappedValue)) {
    return $mappedValue;
  } else {
    print "WARNING: value: $value does not exist in map: $name".
          ", returning ''\n";  
    return [''];  
  }
}
  

sub edPrograms {
  my $self = shift;
  return $$self{$ED_PROGRAM};
}


sub ethnicity {
  my $self = shift;
  return ${$$self{$ETHNICITY}}[0];
}

# returns a ref to a list of filters
#    the list contains hashes, which have the keys $NAME
#    and $VALUE
sub filters {
  my $self = shift;
  return $$self{$FILTER};
}

sub hello {
  "print hello\n";
}
sub studentInfo {
  my $self = shift;
  return $$self{$STUDENT_INFO};
}

# returns a ref to a hash of scores
#   the scores hash has category keys as keys, and hashes as 
#   values, which have a column number as a key, and a hash
#   for its value, which contains a key for the calculation, and
#   for a map, if one is defined for the score
sub scores {
  my $self = shift;
  return $$self{$SCORE}
}

# returns a ref to hash of maps
#    the hash keys are map names, it's values are hashes
#    with acceptable values as keys and mapped values as values
sub maps {
  my $self = shift;
  return $$self{$MAP};
}

# Creates a WHERE clause given a refrence to a list of filters
sub createWhereClause {
  my $self = shift;
  
  my @filters = @{$$self{$FILTER}};
  
  if (scalar(@filters) == 0) {
    return "";
  }
  
  my $whereClause = "WHERE ";
  for (my $i = 0; $i < scalar(@filters); $i++) {
    my %filter = $filters[$i];
    $whereClause .= "$filter{$NAME} = '$filter{$VALUE}' ";
    if ($i < (scalar(@filters) - 1)) {
      $whereClause .= "AND ";
    }
  }
  return $whereClause;
}

sub strip {
  foreach my $val (@_) {
    $$val =~ s/^\s*//;
    $$val =~ s/\s*$//;
  }
}

1;