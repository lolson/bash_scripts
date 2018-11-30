/**
* @See http://directory.apache.org/apacheds/basic-ug/3.1-authentication-options.html
**/
import java.util.Hashtable;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;

public class LDAPClient {
   private static String PROVIDER="ldap://mbs2:10389/";
   public static void main(String[] args) throws NamingException {

        if (args.length < 2) {
            System.err.println("Usage: java LDAPClient <userDN> <password>");
            System.exit(1);
        }
        String ldapSearchURL = LDAPClient.PROVIDER;
        if(args.length > 2) {
            ldapSearchURL = ldapSearchURL + args[2];
        }

        Hashtable env = new Hashtable();
        env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
        env.put(Context.PROVIDER_URL, ldapSearchURL);

        env.put(Context.SECURITY_AUTHENTICATION, "simple");
        env.put(Context.SECURITY_PRINCIPAL, args[0]);
        env.put(Context.SECURITY_CREDENTIALS, args[1]);

        try {
            Context ctx = new InitialContext(env);
            NamingEnumeration enm = ctx.list("");

            while (enm.hasMore()) {
                System.out.println(enm.next());
            }

            enm.close();
            ctx.close();
        } catch (NamingException e) {
            System.out.println(e.getMessage());
        }
    }


}

