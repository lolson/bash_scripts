import java.util.*;
import java.util.Hashtable;
import java.io.IOException;
import javax.management.MBeanServerConnection;
import javax.management.remote.JMXConnector;
import javax.management.remote.JMXConnectorFactory;
import javax.management.remote.JMXServiceURL;
import java.lang.management.MemoryMXBean;
import java.lang.management.ManagementFactory;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import javax.management.*;
import javax.management.openmbean.CompositeDataSupport;

public class TestMBeanServiceMonitor
{
    private static MBeanServerConnection connection;
    private static JMXConnector connector;
    public static void Connection(String hostname, String port) throws IOException
    {
        Integer portInteger = Integer.valueOf(port);
        Hashtable h = new Hashtable();
	String urlString = "service:jmx:remoting-jmx://" + hostname + ":" + port;
//        JMXServiceURL address = new JMXServiceURL("service:jmx:rmi:///jndi/rmi://"+hostname+":"+port+"/jmxrmi");
 	JMXServiceURL address = new JMXServiceURL(urlString);
        connector = JMXConnectorFactory.connect(address,null);
        connection = connector.getMBeanServerConnection();
        System.out.println("GOT THE MBeanServerConnection---SUCCESSFULLY");
    }

    private static void listAllJBossAS7MBeans() throws Exception
    {
        //ObjectName serviceRef=new ObjectName("jboss.as:*");
        //ObjectName serviceRef=new ObjectName("*.*:*");
        ObjectName serviceRef=new ObjectName("*.*:*");
        Set<ObjectName> mbeans = connection.queryNames(serviceRef, null);
        for (ObjectName on : mbeans) {
                  System.out.println("\t ObjectName : "+on);
        }
    }

    private static void getThreadDetails() throws Exception
    {
        ObjectName serviceRef=new ObjectName("java.lang:type=Threading");
        Integer daemonThreadCount=(Integer)connection.getAttribute(serviceRef, "DaemonThreadCount");
        System.out.println("\t daemonThreadCount : "+daemonThreadCount);
    }

    public static void main(String[] args) throws Exception
    {
        String hostname = args[0];
        String port = args[1];
        /*
        ***** The port binding should be defined inside your "standalone-full.xml" file.  *****
        *
        <subsystem xmlns="urn:jboss:domain:jmx:1.1">
            <show-model value="true"/>
            <jmx-connector registry-binding="jmx-connector-registry" server-binding="jmx-connector-server"/>
        </subsystem>
        */

        Connection(hostname, port);
        System.out.println("\n\t All JBoss AS7 MBean Listing \n\n");
        listAllJBossAS7MBeans() ;
    }
}

