
if( $ENV{'NEXUS_STOMP_PORT'} ) {
    $jmsTopic = "jms.topic.";
    $jmsQueue = "jms.queue.";
    print "JMS topic is ", $jmsTopic," \n";
    print "JMS queue is ", $jmsQueue," \n";
} else {
    $jmsTopic = "/topic/";
    $jmsQueue = "/queue/";
    print "JMS topic is ", $jmsTopic," \n";
    print "JMS queue is ", $jmsQueue," \n";
}  

