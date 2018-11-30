package com.emergentspace.gems.display;

import com.emergentspace.nexus.util.SystemUtilities;

/**
 * 
 * <pre>Copyright <a href="http://www.emergentspace.com">Emergent Space Technologies, Inc.</a>
 * See EMERGENT_LICENSE.txt and MGSS_LICENSE.txt for licensing details 
 * 
 * @author <a href="mailto:leif.olson@emergentspace.com">Leif Olson</a>
 */
public class TestDisplayFrame {
public static void main (String[] args) {
       SystemUtilities utils = new SystemUtilities();
       com.emergentspace.nexus.library.UserSession userSession =
               new com.emergentspace.nexus.library.UserSession("localhost", false);
       utils.setUserSession(userSession);
       userSession.login("guest", "guest");

       DisplayViewerPanel panel  = new DisplayViewerPanel();
       //panel.loadDisplay(67);
//        panel.loadDisplay(9);   //default Ground Contacts
//        panel.loadDisplay(6635);   //uses JIDE dial
//        panel.loadDisplay(6646);   //copy of display ID 9
//    panel.loadDisplay(11);   //default Station Keeping Monitoring
        panel.loadDisplay(6654);   //uses random walk

       javax.swing.JFrame window = new javax.swing.JFrame("DisplayViewerPanel");
       window.add(panel);
       window.setSize(300, 300);
       window.setVisible(true);
    }
    
}
