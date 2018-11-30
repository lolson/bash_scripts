import javax.management.MBeanServerConnection;
	import javax.management.remote.JMXConnector;
	import javax.management.remote.JMXConnectorFactory;
	import javax.management.remote.JMXServiceURL;
	import javax.management.*;
	 
	public class JMXAccess {
	    public static void main(String[] args) throws Exception {
            String port= args[0];

	        String host = "localhost";  // Your JBoss Bind Address default is localhost
//	        int port = 4447;  // JBoss remoting port
//	        int port = 9999;  // management native port
	 
	        /*
	          4447 can be enabled in your JBoss Configuration file with the help of the following configuration in your JBoss configuration file
	          <subsystem xmlns="urn:jboss:domain:jmx:1.1">
	              <show-model value="true"/>
	               <remoting-connector  use-management-endpoint="false" />
	          </subsystem>
	        */
	 
	        String urlString ="service:jmx:remoting-jmx://" + host + ":" + port;
	        System.out.println("        \n\n\t****  urlString: "+urlString);
	 
	        JMXServiceURL serviceURL = new JMXServiceURL(urlString);
	        JMXConnector jmxConnector = JMXConnectorFactory.connect(serviceURL, null);
	        MBeanServerConnection connection = jmxConnector.getMBeanServerConnection();
	 
	        ObjectName objectName=new ObjectName("jboss.as:subsystem=messaging,hornetq-server=default");
	 
	        Integer threadPoolMaxSize=(Integer)connection.getAttribute(objectName, "threadPoolMaxSize");
	        Boolean clustered=(Boolean)connection.getAttribute(objectName, "clustered");
	        Boolean createBindingsDir=(Boolean)connection.getAttribute(objectName, "createBindingsDir");
	        Long journalBufferSize=(Long)connection.getAttribute(objectName, "journalBufferSize");
	        Long securityInvalidationInterval=(Long)connection.getAttribute(objectName, "securityInvalidationInterval");
	        Boolean messageCounterEnabled=(Boolean)connection.getAttribute(objectName, "messageCounterEnabled");
	        Integer journalCompactMinFiles=(Integer)connection.getAttribute(objectName, "journalCompactMinFiles");
	        String journalType=(String)connection.getAttribute(objectName, "journalType");
	        Boolean journalSyncTransactional=(Boolean)connection.getAttribute(objectName, "journalSyncTransactional");
	        Integer scheduledThreadPoolMaxSize=(Integer)connection.getAttribute(objectName, "scheduledThreadPoolMaxSize");
	        Boolean securityEnabled=(Boolean)connection.getAttribute(objectName, "securityEnabled");
	        String jmxDomain=(String)connection.getAttribute(objectName, "jmxDomain");
	        Long transactionTimeout=(Long)connection.getAttribute(objectName, "transactionTimeout");
	        String clusterPassword=(String)connection.getAttribute(objectName, "clusterPassword");
	        Boolean createJournalDir=(Boolean)connection.getAttribute(objectName, "createJournalDir");
	        Long messageCounterSamplePeriod=(Long)connection.getAttribute(objectName, "messageCounterSamplePeriod");
	        Boolean persistenceEnabled=(Boolean)connection.getAttribute(objectName, "persistenceEnabled");
	        Boolean allowFailback=(Boolean)connection.getAttribute(objectName, "allowFailback");
	        Long transactionTimeoutScanPeriod=(Long)connection.getAttribute(objectName, "transactionTimeoutScanPeriod");
	        Boolean jmxManagementEnabled=(Boolean)connection.getAttribute(objectName, "jmxManagementEnabled");
	        String securityDomain=(String)connection.getAttribute(objectName, "securityDomain");
	        Long serverDumpInterval=(Long)connection.getAttribute(objectName, "serverDumpInterval");
	        Long failbackDelay=(Long)connection.getAttribute(objectName, "failbackDelay");
	        Integer idCacheSize=(Integer)connection.getAttribute(objectName, "idCacheSize");
	        Long messageExpiryScanPeriod=(Long)connection.getAttribute(objectName, "messageExpiryScanPeriod");
	        Boolean wildCardRoutingEnabled=(Boolean)connection.getAttribute(objectName, "wildCardRoutingEnabled");
	        Integer messageCounterMaxDayHistory=(Integer)connection.getAttribute(objectName, "messageCounterMaxDayHistory");
	        Boolean started=(Boolean)connection.getAttribute(objectName, "started");
	 
	        System.out.println("    threadPoolMaxSize              = "+threadPoolMaxSize);
	        System.out.println("    clustered                      = "+clustered);
	        System.out.println("    createBindingsDir              = "+createBindingsDir);
	        System.out.println("    journalBufferSize              = "+journalBufferSize);
	        System.out.println("    securityInvalidationInterval   = "+securityInvalidationInterval);
	        System.out.println("    messageCounterEnabled          = "+messageCounterEnabled);
	        System.out.println("    journalType                    = "+journalType);
	        System.out.println("    journalSyncTransactional       = "+journalSyncTransactional);
	        System.out.println("    scheduledThreadPoolMaxSize     = "+scheduledThreadPoolMaxSize);
	        System.out.println("    securityEnabled                = "+securityEnabled);
	        System.out.println("    jmxDomain                      = "+jmxDomain);
	        System.out.println("    transactionTimeout             = "+transactionTimeout);
	        System.out.println("    clusterPassword                = "+clusterPassword);
	        System.out.println("    createJournalDir               = "+createJournalDir);
	        System.out.println("    messageCounterSamplePeriod     = "+messageCounterSamplePeriod);
	        System.out.println("    persistenceEnabled             = "+persistenceEnabled);
	        System.out.println("    allowFailback                  = "+allowFailback);
	        System.out.println("    transactionTimeoutScanPeriod   = "+transactionTimeoutScanPeriod);
	        System.out.println("    jmxManagementEnabled           = "+jmxManagementEnabled);
	        System.out.println("    securityDomain                 = "+securityDomain);
	        System.out.println("    serverDumpInterval             = "+serverDumpInterval);
	        System.out.println("    failbackDelay                  = "+failbackDelay);
	        System.out.println("    idCacheSize                    = "+idCacheSize);
	        System.out.println("    messageExpiryScanPeriod        = "+messageExpiryScanPeriod);
	        System.out.println("    wildCardRoutingEnabled         = "+wildCardRoutingEnabled);
	        System.out.println("    messageCounterMaxDayHistory    = "+messageCounterMaxDayHistory);
	        System.out.println("    started                        = "+started);
	 
	        jmxConnector.close();
	    }
	}
