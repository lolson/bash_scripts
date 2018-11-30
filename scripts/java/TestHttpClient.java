import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.methods.GetMethod;
import java.io.IOException;
import org.apache.log4j.Logger;
import com.emergentspace.mbs.util.*;

public class TestHttpClient {
    private static String trustStore = "";
    private static String trustStorePassword = "";
    public static void main(String args[]) {
//        String serviceUrl = "http://192.168.10.73:9763/services";
        String serviceUrl = "https://192.168.10.73:9443/services";
        trustStore = args[0];
        trustStorePassword = args[1];
        testConnectToHost(serviceUrl);
    }

    public static boolean testConnectToHost(String serviceUrl) {
        setupSSL();
        HttpClient client = new HttpClient();
        client.setTimeout(5000);
        
        String baseUrl = getBaseUrl(serviceUrl);
        print(baseUrl);
        GetMethod get = new GetMethod(getBaseUrl(serviceUrl));
        int status;
        try {
            status = client.executeMethod(get);
            if (status == 200) {
                print("Connected to web services host => " + serviceUrl);
                return true;
            } else {
                print("Web services connection error => " + serviceUrl + "; Http status error code: " + status);
            }
        } catch (IOException ex) {
            print("Web services connection error =>  " + serviceUrl + "; " + ex.toString());
            ex.printStackTrace();
        } finally {
            get.releaseConnection();
        }
        return false;
    }

    private static String getBaseUrl(String serviceUrl) {
        String[] urlElem = serviceUrl.split("//");
        String protocol = urlElem[0];
        String[] hostPath = urlElem[1].split("/");
        String host = hostPath[0];
        return protocol + "//" + host;
    }

    private static void setupSSL() {

          try {
                System.setProperty("javax.net.ssl.trustStore", trustStore); 
//                System.setProperty("javax.net.ssl.trustStorePassword", CryptoUtil.decrypt(trustStorePassword));
                System.setProperty("javax.net.ssl.trustStorePassword", "wso2carbon");
            } catch (Exception e) {
                String errorMsg = "Failed to setup trust store";
                print(errorMsg);
                e.printStackTrace();
            }
    }

    private static void print(String s) {
        System.out.println(s);
    }
}
