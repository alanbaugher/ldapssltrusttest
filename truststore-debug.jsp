<%@ page import="java.util.Hashtable" %>
<%@ page import="javax.naming.*" %>
<%@ page import="javax.naming.directory.*" %>
<%@ page import="java.net.InetAddress" %>
<%@ page import="java.io.FileInputStream" %>
<%@ page import="java.security.KeyStore" %>
<%@ page import="java.security.cert.*" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.util.*" %>
<%@ page import="javax.net.ssl.TrustManager" %>
<%@ page import="javax.net.ssl.TrustManagerFactory" %>
<%@ page import="javax.net.ssl.X509TrustManager" %>

<%
response.setContentType("text/plain");

String trustStore = System.getProperty("javax.net.ssl.trustStore");
String trustStorePassword = System.getProperty("javax.net.ssl.trustStorePassword");
String validatorEngine = System.getProperty("com.sun.security.validator.engine");

out.println("===== TrustStore Debug =====\n");

out.println("javax.net.ssl.trustStore: " + trustStore);
out.println("javax.net.ssl.trustStorePassword: " + trustStorePassword);
out.println("com.sun.security.validator.engine: " + validatorEngine);
out.println();

try {
    FileInputStream fis = new FileInputStream(trustStore);
    KeyStore ks = KeyStore.getInstance(KeyStore.getDefaultType());
    ks.load(fis, trustStorePassword.toCharArray());

    out.println("TrustStore contains " + ks.size() + " entries:");
    Enumeration<String> aliases = ks.aliases();
    while (aliases.hasMoreElements()) {
        String alias = aliases.nextElement();
        Certificate cert = ks.getCertificate(alias);
        if (cert instanceof X509Certificate) {
            X509Certificate x509 = (X509Certificate) cert;
            out.println("Alias: " + alias);
            out.println("  Subject: " + x509.getSubjectDN());
            out.println("  Issuer:  " + x509.getIssuerDN());
            out.println("  Serial:  " + x509.getSerialNumber().toString(16));
            out.println("  Valid From: " + x509.getNotBefore());
            out.println("  Valid To  : " + x509.getNotAfter());

            try {
                Collection<List<?>> san = x509.getSubjectAlternativeNames();
                if (san != null) {
                    out.println("  Subject Alternative Names:");
                    for (List<?> item : san) {
                        out.println("    " + item.get(1));
                    }
                }
            } catch (Exception ex) {
                out.println("  SAN parse error: " + ex.getMessage());
            }

            boolean[] ku = x509.getKeyUsage();
            if (ku != null) {
                String[] kuNames = {
                    "digitalSignature", "nonRepudiation", "keyEncipherment",
                    "dataEncipherment", "keyAgreement", "keyCertSign",
                    "cRLSign", "encipherOnly", "decipherOnly"
                };
                out.print("  KeyUsage: ");
                for (int i = 0; i < ku.length; i++) {
                    if (ku[i]) out.print(kuNames[i] + " ");
                }
                out.println();
            }

            out.println("  BasicConstraints (CA): " + x509.getBasicConstraints());
            out.println();
        }
    }
    fis.close();
} catch (Exception e) {
    out.println("Error reading trust store:");
    e.printStackTrace(new PrintWriter(out));
}
out.println();

String hostname = "vapp2025";
try {
    InetAddress address = InetAddress.getByName(hostname);
    out.println("DNS resolution for '" + hostname + "':");
    out.println("Resolved to IP: " + address.getHostAddress());
} catch (Exception e) {
    out.println("DNS resolution failed:");
    e.printStackTrace(new PrintWriter(out));
}
out.println();

try {
    Hashtable<String, String> env = new Hashtable<>();
    env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
    env.put(Context.PROVIDER_URL, "ldaps://" + hostname + ":10101");
    env.put(Context.SECURITY_AUTHENTICATION, "simple");
    env.put(Context.SECURITY_PRINCIPAL, "cn=dsaadmin,ou=im,ou=ca,o=com");
    env.put(Context.SECURITY_CREDENTIALS, "Password01!");

    DirContext ctx = new InitialDirContext(env);
    out.println("LDAP bind succeeded");
    ctx.close();
} catch (Exception e) {
    out.println("LDAP bind failed:");
    e.printStackTrace(new PrintWriter(out));
}
out.println();

try {
    TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
    FileInputStream tsStream = new FileInputStream(trustStore);
    KeyStore ks = KeyStore.getInstance(KeyStore.getDefaultType());
    ks.load(tsStream, trustStorePassword.toCharArray());
    tmf.init(ks);

    X509TrustManager tm = null;
    for (TrustManager t : tmf.getTrustManagers()) {
        if (t instanceof X509TrustManager) {
            tm = (X509TrustManager) t;
            break;
        }
    }

    if (tm != null) {
        out.println("TrustManager accepted issuers:");
        for (X509Certificate cert : tm.getAcceptedIssuers()) {
            out.println("  - " + cert.getSubjectDN());
        }
    } else {
        out.println("No X509TrustManager found.");
    }

    tsStream.close();
} catch (Exception e) {
    out.println("TrustManagerFactory init failed:");
    e.printStackTrace(new PrintWriter(out));
}
%>
