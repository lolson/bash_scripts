
$jmsTopic = $ENV{'NEXUS_STOMP_PORT'} ? "jms.topic." : "/topic/";
$jmsQueue = $ENV{'NEXUS_STOMP_PORT'} ? "jms.queue." : "/queue/";
    print "JMS topic is ", $jmsTopic," \n";
    print "JMS queue is ", $jmsQueue," \n";

#my $subject = checkWildcard('NEXUS.#.#.REQ.DIR.GEMS_SYSTEM_AGENT');

#use constant SUBJECT => $ENV{'NEXUS_STOMP_PORT'} ? 'NEXUS.#.#.REQ.DIR.GEMS_SYSTEM_AGENT' 
 #                                               : 'NEXUS.*.*.REQ.DIR.GEMS_SYSTEM_AGENT';
$subject = &checkWildcard('NEXUS.*.*.REQ.DIR.GEMS_SYSTEM_AGENT');
#use constant subjConstant = 'GEMS';

sub checkWildcard {
    if( $ENV{'NEXUS_STOMP_PORT'} ) {
        $subj = $_[0];
        print "Before ",$subj,"\n";
        $subj =~ s/\*/#/g;
        print "After ",$subj,"\n";
        return $subj; 
    } else {
        return $_[0];
    }
}

sub checkIt {
    if( $ENV{'NEXUS_STOMP_PORT'} ) {
        return $_[0] =~ s/\*/#/g; 
    } else {
        return $_[0];
    }
}


print "Subj ", $subject, "\n";
print "Subj constant ", $subjConstant, "\n";
$this = &checkIt('NEXUS.*.*.REQ.DIR.GEMS_SYSTEM_AGENT');
print "this ",$this,"\n";
my $jmsQueue = $ENV{'NEXUS_STOMP_PORT'} ? "jms.queue." : "/queue/";  

#my SUBJECT = Nexus::Session::checkWildcard('NEXUS.#.#.REQ.DIR.GEMS_SYSTEM_AGENT')
