// Use to test difference between 'simple' and 'pkix' enforcement of public root CA cert
// JxWeb appears to use older enforcement of 'pkix'
// Jxplorer and Apache Dir Studio use relaxed 'simple' enforcement if a public root CA cert is offered
// Compile:   /opt/CA/java/bin/javac LdapSSLTrustTest.java
// Test:      java -Djavax.net.debug=ssl:handshake:verbose:certpath:trustmanager LdapSSLTrustTest
//
// Validate credentials prior:
// LDAPTLS_REQCERT=never ldapsearch -LLL -H ldaps://$(hostname):10101 -D 'cn=dsaadmin,ou=im,ou=ca,o=com' -w Password01! -s base
// LDAPTLS_REQCERT=never ldapsearch -d9  -H ldaps://$(hostname):10101 -D 'cn=dsaadmin,ou=im,ou=ca,o=com' -w Password01! -s base
//
//  ANA 06/2025


import javax.net.ssl.*;
import java.security.KeyStore;
import java.security.cert.X509Certificate;
import java.util.Hashtable;
import javax.naming.Context;
import javax.naming.directory.DirContext;
import javax.naming.directory.InitialDirContext;

public class LdapSSLTrustTest {

    private static final String HOST = "vapp2025";
    private static final int PORT = 10101;
    private static final String URL = "ldaps://" + HOST + ":" + PORT;

    private static final String TRUSTSTORE = "keystore.jks";
    private static final String TRUSTSTORE_PASSWORD = "changeit";

    private static final String BIND_DN = "cn=dsaadmin,ou=im,ou=ca,o=com";
    private static final String BIND_PW = "Password01!";


    public static void main(String[] args) throws Exception {
        System.out.println("===== PKIX Validator Test =====");
        System.out.println("===== PKIX Validator Test =====");
        System.out.println("===== PKIX Validator Test =====");
        System.setProperty("com.sun.security.validator.engine", "pkix");
        try {
            connectWithStandardContext();
            System.out.println("✅ PKIX connection succeeded");
            System.out.println("✅ PKIX connection succeeded");
            System.out.println("✅ PKIX connection succeeded");
        } catch (Exception e) {
            System.out.println("❌ PKIX connection failed:");
            System.out.println("❌ PKIX connection failed:");
            System.out.println("❌ PKIX connection failed:");
            e.printStackTrace(System.out);
        }

        System.out.println("\n");
        System.out.println("===== Simple Validator Test =====");
        System.out.println("===== Simple Validator Test =====");
        System.out.println("===== Simple Validator Test =====");
        System.setProperty("com.sun.security.validator.engine", "simple");
        try {
            connectWithStandardContext();
            System.out.println("✅ Simple connection succeeded");
            System.out.println("✅ Simple connection succeeded");
            System.out.println("✅ Simple connection succeeded");
        } catch (Exception e) {
            System.out.println("❌ Simple connection failed:");
            System.out.println("❌ Simple connection failed:");
            System.out.println("❌ Simple connection failed:");
            e.printStackTrace(System.out);
        }
    }

    private static void connectWithStandardContext() throws Exception {
        // Setup truststore
        System.setProperty("javax.net.ssl.trustStore", TRUSTSTORE);
        System.setProperty("javax.net.ssl.trustStorePassword", TRUSTSTORE_PASSWORD);

        Hashtable<String, String> env = new Hashtable<>();
        env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
        env.put(Context.PROVIDER_URL, URL);
        env.put(Context.SECURITY_AUTHENTICATION, "simple");
        env.put(Context.SECURITY_PRINCIPAL, BIND_DN);
        env.put(Context.SECURITY_CREDENTIALS, BIND_PW);

        // OPTIONAL: Uncomment to explicitly use default SSL socket
        // env.put("java.naming.ldap.factory.socket", "javax.net.ssl.SSLSocketFactory");

        DirContext ctx = new InitialDirContext(env);
        ctx.close();

        // Prevent SSL race condition warnings by giving background threads time to shut down
        Thread.sleep(500);
    }
}
