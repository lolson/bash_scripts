
use IO::File;
use GMSEC::LogMessage;
use GMSEC::Field;
use GMSEC::MessageBody;
use Math::Complex;

use Nexus::ConnectionFactory;
use Log::Log4perl qw(get_logger);

my $context = get_logger("RANDOMPIE");

$context->info('Starting random walk');

my $host = 'localhost';
my $port = 61613;
my $connection = Nexus::ConnectionFactory::createConnection($host, $port);
my $session = $connection->createSession;

my $log = GMSEC::LogMessage->new(1, "random walk generator");
$log->setMsgTextDetails("Look at the fields for the details");
$log->setSubject("NEXUS.RANDOM.PIE");

my $publisher = $session->createPublisher($log->getSubject);

my $x = 0.0;
my $y = 0.0;
my $z = 0.0;
my $a = 0.0;
my $b = 0.0;

my $msgCount = 0;

while (1) {

$x = $x + (1 + 2*rand(1));
$y = $y + (1 + 2*rand(1));
$z = $z + (1 + 2*rand(1));
$a = $a + (1 + 2*rand(1));
$b = $b + (1 + 2*rand(1));

$log->addField(GMSEC_TYPE_STRING, "POINT", "X,$x,Y,$y,Z,$z,A,$a,B,$b");

my $msg = $session->createMessage;
$msg->setBody($log->getContents);
++$msgCount;
$publisher->publish($msg);
sleep 1;
}

$session->close;
