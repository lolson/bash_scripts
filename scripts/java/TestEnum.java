package com.emergentspace.mbs.mbs;

import com.emergentspace.mbs.util.CxnHelper;
import com.emergentspace.mbs.util.CxnHelper.Postprocessor;
import com.emergentspace.mbs.util.CxnHelper.Preprocessor;
import com.emergentspace.mbs.util.PolicyHelper.MessageType;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * 
 * <pre>Copyright <a href="http://www.emergentspace.com">Emergent Space Technologies, Inc.</a>
 * See EMERGENT_LICENSE.txt and AFRL_SBIR_LICENSE_1.txt for licensing details.</pre>
 * 
 * @author <a href="mailto:leif.olson@emergentspace.com">Leif Olson</a>
 */
public class TestEnum {
    private static void getEnum(String value) {
        try {
            System.out.println(
            CxnHelper.Preprocessor.class.getDeclaredField(value));
        } catch (NoSuchFieldException ex) {
            Logger.getLogger(TestEnum.class.getName()).log(Level.SEVERE, null, ex);
        } catch (SecurityException ex) {
            Logger.getLogger(TestEnum.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private static List<String> orderPreTypes(Set<String> preTypes) {
          List<Preprocessor> preList = new ArrayList<Preprocessor>();
          for(String type : preTypes) {
              preList.add(Preprocessor.fromString(type));
          }
          Collections.sort(preList);
          List<String> orderTypes = new ArrayList<String>();
          for(Preprocessor p : preList) {
              orderTypes.add(p.getType());
          }
          return orderTypes;
    }

    private static List<String> orderPostTypes(Set<String> postTypes) {
        List<Postprocessor> postList = new ArrayList<Postprocessor>();
        for (String type : postTypes) {
            postList.add(Postprocessor.fromString(type));
        }
        Collections.sort(postList);
        List<String> orderTypes = new ArrayList<String>();
        for(Postprocessor p : postList) {
            orderTypes.add(p.getType());
        }
        return orderTypes;
    }

    //Apply enumeration defined ordering to list of message patterns
    public static List<String> orderMessageTypes(Set<String> patterns) {
        List<MessageType> patternEnums = new ArrayList<MessageType>();
        for(String pat : patterns) {
            patternEnums.add(MessageType.fromString(pat));
        }
        Collections.sort(patternEnums);
        List<String> orderedTypes = new ArrayList<String>();
        for(MessageType p : patternEnums) {
            orderedTypes.add(p.toString());
        }
        return orderedTypes;
    }

    private static void testOrderMessageTypes() {
        Set<String> set1 = new HashSet();
        set1.add("reply");
        set1.add("request");
        for(String pat : orderMessageTypes(set1)) {
            System.out.println("First: "+pat);
        }
        set1.add("subscribe");
        set1.add("publish");
        for(String pat : orderMessageTypes(set1)) {
            System.out.println("Second: "+pat);
        }
        Set<String> set2 = new HashSet();
        set2.add("publish");
        set2.add("subscribe");
        for(String pat : orderMessageTypes(set2)) {
            System.out.println("Third: "+pat);
        }
    }
    
      public static void main(String[] args) {
          testOrderMessageTypes();
          /*
          List<Preprocessor> preP = new ArrayList<Preprocessor>();
          String[] preTypes = "unzip,decrypt_aes".split(",");
          String[] preTypes2 = "decrypt_aes,unzip".split(",");
          for(String type : preTypes) {
              preP.add(Preprocessor.fromString(type));
          }
          Collections.sort(preP);
          String orderedPre = preP.get(0).getType();
          for(int i = 1; i < preP.size(); i++) {
              orderedPre += ",";
              orderedPre += preP.get(i).getType();
          }
          Set<String> set1 = new HashSet();
          set1.add("unzip");
          set1.add("decrypt_aes");
          System.out.println(orderPreTypes(set1));
          Set<String> set2 = new HashSet();
          set2.add("decrypt_aes");
          set2.add("unzip");
          System.out.println(orderPreTypes(set2));
          * */
//          System.out.println(orderPostTypes("encrypt_aes,zip"));
//          System.out.println(orderPostTypes("zip,encrypt_aes"));
          
/*
          List<String> desc = new ArrayList<String>();
        for(Enum e : CxnHelper.Preprocessor.class.getEnumConstants()) {
           desc.add(e.name()); 
        }
        Preprocessor p = CxnHelper.Preprocessor.fromString("unzip");
        
          System.out.println(p.getLabel());
        
        
          System.out.println(desc);
          List<String> postDesc = new ArrayList<String>();
          for(Enum e : CxnHelper.Postprocessor.class.getEnumConstants()) {
              postDesc.add(e.name());              
          }
          System.out.println(postDesc);
          * */
    }
}
