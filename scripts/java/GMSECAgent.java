package gov.nasa.gsfc.cof.dashboard.data;

//import com.emergentspace.mbs.data.BridgeMessage;
//import com.emergentspace.mbs.data.CommonMessage;
import com.emergentspace.nexus.gmsec.DirectiveRequest;
import com.emergentspace.nexus.gmsec.DirectiveResponse;
import com.emergentspace.nexus.gmsec.MessageBody;
import com.emergentspace.nexus.util.MessageUtilities;
import gov.nasa.gsfc.gmsecapi.Callback;
import gov.nasa.gsfc.gmsecapi.Config;
import gov.nasa.gsfc.gmsecapi.Connection;
import gov.nasa.gsfc.gmsecapi.ConnectionFactory;
import gov.nasa.gsfc.gmsecapi.GMSEC_String;
import gov.nasa.gsfc.gmsecapi.GMSEC_UShort;
import gov.nasa.gsfc.gmsecapi.Message;
import gov.nasa.gsfc.gmsecapi.Status;
import gov.nasa.gsfc.gmsecapi.gmsecAPI;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.jms.MessageConsumer;
import javax.jms.MessageListener;
import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

/**
 * GMSEC agent for the communications protocol adapter
 *
 * <pre>Copyright <a href="http://www.emergentspace.com">Emergent Space Technologies, Inc.</a>
 * See EMERGENT_LICENSE.txt and AFRL_SBIR_LICENSE_2.txt for licensing details.</pre>
 * Aslo see Telemetry Recorder EJB
 * @author <a href="mailto:timothy.esposito@emergentspace.com">Timothy
 * Esposito</a>
 */
public class GMSECAgent implements Runnable, MessageListener, Callback {

    private static final Logger logger = Logger.getLogger(GMSECAgent.class);
    private boolean remote = false;
    private boolean connected = false;
    private boolean running = false;
    private final int connConfigID;
    private final String connConfigName;
    private List<String> inSubjects;
    private final ConcurrentHashMap<String, Pattern> inSubjPatternMap;
    private Config gmsecConfig;
    private Connection gmsecConn;
    private Status result;
//    private GMSECConnection protocolAdapter;
    private MessageUtilities msgUtils;
    private MessageConsumer controlListener;
    private String adapterQueue, responseQueue;

    public GMSECAgent(int connConfigID, String connConfigName) {
        this.connConfigID = connConfigID;
        this.connConfigName = connConfigName;
        inSubjPatternMap = new ConcurrentHashMap<String, Pattern>();
    }

    // used for local agent mode
//    public void setProtocolAdapter(GMSECConnection protocolAdapter) {
//        this.protocolAdapter = protocolAdapter;
//    }

    // run is used for remote agent mode only where all actions are triggered by messages
    @Override
    public void run() {
        remote = true;
        msgUtils = new MessageUtilities();
        //controlListener = msgUtils.assignListenerToTopic("MBS.GMSEC_AGENT." + connConfigID, this);
        responseQueue = "MBS.GMSEC_ADAPTER.RESP." + connConfigID;

        try {
            msgUtils.connectToQueue("MBS.GMSEC_AGENT." + connConfigID);
            controlListener = msgUtils.setMessageListener(this);
        } catch (Exception e) {
            logger.error("Failed to subscribe to GMSEC agent queue => " + connInfo() + "; " + e.toString());
        }

        // keep process alive
        while (controlListener != null) {
            try {
                Thread.sleep(60000);
            } catch (Exception e) {
            }
        }
    }

    public boolean connect(String gmsecConfigParams) {
        logger.info("Connecting to GMSEC => " + connInfo() + ", " + gmsecConfigParams);

        showEnv();

        gmsecConfig = new Config();

        for (String p : gmsecConfigParams.split(";")) {
            String[] nv = p.split("=");
            if (nv.length == 2) {
                gmsecConfig.AddValue(nv[0], nv[1]);
            }
        }

        gmsecConn = new Connection();
        result = ConnectionFactory.Create(gmsecConfig, gmsecConn);

        if (result.isError()) {
            logger.error("GMSEC connection error => " + result.Get());

        } else {
            //logger.info("GMSSEC connection created => " + result.Get()); //debug

            result = gmsecConn.Connect();

            if (!result.isError()) {
                logger.info("GMSEC connection successful => " + connInfo());
                connected = true;
            } else {
                String errorMsg = "GMSEC connection failed => " + connInfo() + "; " + result.Get();
                logger.error(errorMsg);
                //createStatsEvent(errorMsg);
                connected = false;
            }
        }

        /*if (connected && pubHB) {
         pubHeartbeats();
         }*/
        return connected;
    }

    public boolean disconnect() {
        if (gmsecConn == null) {
            return false;
        }

        result = gmsecConn.Disconnect();

        if (result.isError()) {
            logger.error("Error disconnecting => " + connInfo() + "; " + result.Get());
            return false;
        } else {
            connected = false;
            running = false;
        }

        return true;
    }

    public boolean isRemote() {
        return remote;
    }

    public boolean isConnected() {
        return connected;
    }

    public boolean isRunning() {
        return running;
    }

    public boolean startMessaging(List<String> inSubjects) {
        //stats.setRunning(false);
        running = false;
        this.inSubjects = inSubjects;

        inSubjPatternMap.clear();

        if (inSubjects.size() > 0) {
            convert2Pattern(inSubjects, inSubjPatternMap);
        } else {
            logger.warn("GMSEC connection has no incoming subjects specified => " + connInfo());
        }

        if (gmsecConn != null) {
            for (String s : inSubjects) {
                result = gmsecConn.Subscribe(s, this);

                if (result.GetClass() != gmsecAPI.GMSEC_STATUS_NO_ERROR) {
                    logger.error("Failed to subscribe to GMSEC subject => " + s + ", error=" + result.Get());
                }
            }

            result = gmsecConn.StartAutoDispatch();

            if (result.isError()) {
                logger.error("Failed to start auto dispatcher for connection => " + connInfo() + ", error=" + result.Get());
            } else {
                running = true;
            }
        }

        return running;
    }

    public boolean pubHeartbeats() {

//     Message hbMsg = new Message();
/*        if (gmsecSupport.getMessage(gc, "message.publish.hb", hbMsg)) {
         HeartbeatPublisher hb = new HeartbeatPublisher(gc, Short.parseShort(hbRate), hbMsg);
         hbPublishers.add(hb);
         hb.start();

         } else {
         logger.error("Failed to load heartbeat message from GMSEC configuration file");
         }
         }
         */
        return false;
    }

    public boolean stopMessaging() {
        if (gmsecConn != null) {
            for (String s : inSubjects) {
                gmsecConn.UnSubscribe(s, this);
            }

            gmsecConn.StopAutoDispatch();
        }

        running = false;
        return running;
    }

    // handle control messages from the GMSEC communications protocol adapter
    @Override
    public synchronized void onMessage(javax.jms.Message msg) {
        try {
            Boolean rvBool = null;
            Integer rvInt = null;

            DirectiveRequest req = new DirectiveRequest(msg);            
            String dir = req.getDirectiveKeyword();

            /*
            if (dir.equals("CONNECT")) {
                String gmsecConfigParams = req.getFieldValue("gmsecConfigParams");
                rvBool = connect(gmsecConfigParams);

            } else if (dir.equals("DISCONNECT")) {
                rvBool = disconnect();

            } else if (dir.equals("START_MESSAGING")) {
                List<String> inputSubjects = new ArrayList<String>();
                int numSubjects = req.getField("inputSubjects.count").getValueI32();
                for (int s = 1; s <= numSubjects; s++) {
                    inputSubjects.add(req.getFieldValue("inputsSubjects." + s));
                }
                rvBool = startMessaging(inputSubjects);

            } else if (dir.equals("STOP_MESSAGING")) {
                rvBool = stopMessaging();

            } else if (dir.equals("SEND_MESSAGE")) {
                com.emergentspace.nexus.gmsec.Field msgField = req.getField("msgBytes");
                byte[] msgBytes = msgField.getValueBIN();
                BridgeMessage bridgeMsg = new CommonMessage(msgBytes);
                rvInt = sendMessage(bridgeMsg);

            } else if (dir.equals("SHUTDOWN_AGENT")) {
                logger.info("Exiting system agent => " + connInfo());
                stopMessaging();
                disconnect();
                System.exit(0);
            }
*/
            // send an acknoweldgement back to the GMSEC adapter
            DirectiveResponse resp = new DirectiveResponse(msgUtils.getRandom("GA"), "3");
            resp.setData(dir);

            if (rvBool != null) {
                resp.setReturnValue(rvBool ? "1" : "0");
            } else if (rvInt != null) {
                resp.setReturnValue(String.valueOf(rvInt));
            }

            resp.setSubject(responseQueue);
            msgUtils.sendMessage(responseQueue, resp);

        } catch (Exception e) {
            logger.error("Failed to process GMSEC agent control message => " + connInfo() + "; " + e.toString());
        }
    }

    // where GMSEC messages are received
    @Override
    public synchronized void OnMessage(Connection conn, Message msg) {
        boolean subjMatch = false;
        gov.nasa.gsfc.gmsecapi.Field gMsgField = new gov.nasa.gsfc.gmsecapi.Field();
        Status status;

        try {
            GMSEC_String xml = new GMSEC_String();
            msg.ToXML(xml);
            String xmlS = xml.toString();

            GMSEC_String subject = new GMSEC_String();
            msg.GetSubject(subject);
            String subj = subject.toString();

            /*GMSEC_ULong msgSize = new GMSEC_ULong();
             msg.GetMSGSize(msgSize);
             long mSize = msgSize.Get();
             logger.info(" GMSEC Message Size: " + mSize + " GMSEC orig size: " + msgSize);
             logger.info(" GMSEC Message direct conversion: " + msgSize.Get());*/
            GMSEC_UShort kind = new GMSEC_UShort();
            msg.GetKind(kind);
            int mKind = kind.Get();

            // convert message subject to regex in Pattern object
            for (String s : inSubjPatternMap.keySet()) {
                Matcher m = inSubjPatternMap.get(s).matcher(subj);
                if (m.matches()) {
                    //logger.debug("Matched subject pattern => " + s);
                    subjMatch = true;
                    break;
                }
            }

            if (!subjMatch) {
                // report message received
                if (remote) {
                    // send a directive to adapter to record recieved message
                    DirectiveRequest req = new DirectiveRequest(msgUtils.getRandom("GA"), "RECEIVED_MESSAGE", "RECEIVED_MESSAGE");
                    req.setSubject(adapterQueue);
                    req.addField(com.emergentspace.nexus.gmsec.Field.GMSEC_TYPE_I32, "msgSize", xmlS.length());
                    msgUtils.sendMessage(adapterQueue, req);

                } else {
//                    protocolAdapter.receivedMessage(xmlS.length());
                }

                return; // no need to process msg since no one is interested in
            }

            String msgNode = "";
            status = msg.GetField("NODE", gMsgField);
            if (status.isError()) {
                logger.info("Unable to retrieve NODE field from GMSEC message => " + connInfo() + "; " + status.Get());
            } else {
                GMSEC_String gmMsgNode = new GMSEC_String();
                gMsgField.GetValueSTRING(gmMsgNode);
                msgNode = gmMsgNode.Get();
            }
//            BridgeMessage gmsecBM = new CommonMessage(xmlS);
//            gmsecBM.setSubject(subj);

            // set message type in GMSEC Messsage object based on incoming message
//            if (mKind == gmsecAPI.GMSEC_MSG_REQUEST || subject.Get().contains("REQ")) {
//                gmsecBM.setType(MessageBody.GMSEC_MSG_REQUEST);
//            } else if (mKind == gmsecAPI.GMSEC_MSG_PUBLISH) {
//                gmsecBM.setType(MessageBody.GMSEC_MSG_PUBLISH);
//            } else {
                logger.error("Message type expected to be request or publish => " + connInfo() + ", subject=" + subj + ", kind=" + mKind);
//            }

            // deliver message to GMSEC communications protocol adapter
//            if (remote) {
                // send a directive to adapter to record recieved message
                DirectiveRequest req = new DirectiveRequest(msgUtils.getRandom("GA"), "PROCESS_MESSAGE", "PROCESS_MESSAGE");
                req.setSubject(adapterQueue);
                req.addField(com.emergentspace.nexus.gmsec.Field.GMSEC_TYPE_STRING, "msgSize", msgNode);
                req.addField(com.emergentspace.nexus.gmsec.Field.GMSEC_TYPE_I32, "msgSize", xmlS.length());
//                req.addField(com.emergentspace.nexus.gmsec.Field.GMSEC_TYPE_BIN, "msgSize", gmsecBM.getContents());
                msgUtils.sendMessage(adapterQueue, req);
//
//            } else {
//                protocolAdapter.processMessage(msgNode, xmlS.length(), gmsecBM);
//            }

        } catch (Exception e) {
            logger.error("Failure occurred while processing message on connection => " + connInfo() + ", error=" + e);
        }
    }

    // TODO: Postprocessing needs to happen in the sendMessage(), just to the payload
//    public int sendMessage(BridgeMessage msg) {
//        Message gmsecMsg = new Message();
//
//        gmsecConn.CreateMessage(gmsecMsg);
//        gmsecMsg.SetSubject(msg.getSubject());
//
//        short mType = msg.getType();
//
//        if (mType == MessageBody.GMSEC_MSG_REPLY) {
//            gmsecMsg.SetKind(gmsecAPI.GMSEC_MSG_REPLY);
//        } else if (mType == MessageBody.GMSEC_MSG_PUBLISH) {
//            gmsecMsg.SetKind(gmsecAPI.GMSEC_MSG_PUBLISH);
//        } else {
//            gmsecMsg.SetKind(gmsecAPI.GMSEC_MSG_UNSET);
//        }
//
//        String xmlS = msg.toXML();
//        gmsecMsg.FromXML(xmlS);
//
//        result = gmsecConn.Publish(gmsecMsg);
//
//        gmsecConn.DestroyMessage(gmsecMsg);
//
//        if (result.GetClass() != gmsecAPI.GMSEC_STATUS_NO_ERROR) {
//            logger.error("Failed to publish GMSEC message => " + connInfo() + ", topic=" + msg.getSubject() + ", error=" + result.Get());
//            return -1;
//        } else {
//            return xmlS.length();
//        }
//    }

    public static void convert2Pattern(List<String> values, ConcurrentHashMap stringPatternMap) {
        String regex;
        for (String s : values) {
            regex = s.replace(".", "\\.");

            if (s.contains("*") || s.contains(">")) {
                regex = regex.replace("*", "\\w+");
                regex = regex.replace(">", ".*");
            }

            Pattern pattern = Pattern.compile(regex);
            stringPatternMap.put(s, pattern);
        }
        logger.info("Subject pattern keys => " + stringPatternMap.keySet());
    }

    public String connInfo() {
        return "[" + connConfigID + "] " + connConfigName;
    }

    @Override
    public void finalize() {
        if (controlListener != null) {
            try {
                controlListener.close();
            } catch (Exception e) {
            }
        }
    }

    public static void showEnv() {
        for (Map.Entry<String, String> entry : System.getenv().entrySet()) {
            String key = entry.getKey();
            if (key.equals("GMSEC_HOME") || key.equals("LD_LIBRARY_PATH") || key.equals("LD_PRELOAD")) {
                logger.info("Environment variable => " + key + "=" + entry.getValue());
            }
        }
    }

    /**
     * Change the in-memory environment variable value for LD_PRELOAD This works
     * in Linux, but a solution for Windows also exists. See link ...
     * http://stackoverflow.com/questions/318239/how-do-i-set-environment-variables-from-java
     *
     * @param var Environment variable
     * @param value New value for environment variable LD_PRELOAD
     * @param prependPath Should value be prepended as a path
     */
    public static void setEnvVar(String var, String value, boolean prependPath) {
        Class[] classes = Collections.class.getDeclaredClasses();
        Map<String, String> env = System.getenv();
        for (Class cl : classes) {
            if ("java.util.Collections$UnmodifiableMap".equals(cl.getName())) {
                try {
                    Field field = cl.getDeclaredField("m");
                    field.setAccessible(true);
                    Object obj = field.get(env);
                    Map<String, String> map = (Map<String, String>) obj;

                    if (prependPath) {
                        String currentValue = System.getenv(var);
                        if (currentValue != null) {
                            value = value + File.pathSeparator + currentValue;
                        }
                    }

                    map.put(var, value);
                } catch (Exception e) {
                    logger.error("Failed to set environment variable => " + var + "=" + value + "; " + e.toString());
                }
            }
        }
    }

    public static void main(String args[]) {
        String LOG4J_PROPERTIES = "com/emergentspace/mbs/log4j.properties";
        Properties props = new Properties();
        InputStream log4jStream = null;

        try {
            log4jStream = Thread.currentThread().getContextClassLoader().getResourceAsStream(LOG4J_PROPERTIES);
            props.load(log4jStream);

        } catch (IOException ex) {
            System.out.println("Error loading log4j properties file => " + LOG4J_PROPERTIES);

        } finally {
            if (log4jStream != null) {
                try { log4jStream.close(); } catch (Exception e) { }
            }
        }

        PropertyConfigurator.configure(props);

        if (args.length == 2) {
            GMSECAgent agent = new GMSECAgent(Integer.parseInt(args[0]), args[1]);
            agent.run();
        }

    }
}


