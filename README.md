# ldapssltrusttest
Test LDAP SSL Trust via external java or internal JSP page


LDAPTLS_REQCERT=never ldapsearch -LLL -H ldaps://$(hostname):10101 -D 'cn=dsaadmin,ou=im,ou=ca,o=com' -w Password01! -s base
LDAPTLS_REQCERT=never ldapsearch -d9  -H ldaps://$(hostname):10101 -D 'cn=dsaadmin,ou=im,ou=ca,o=com' -w Password01! -s base

/opt/CA/java/bin/javac LdapSSLTrustTest.java

java -Djavax.net.debug=ssl:handshake:verbose:certpath:trustmanager LdapSSLTrustTest


![image](https://github.com/user-attachments/assets/d2fdfe63-3235-49fd-965a-6b4108853c55)


Attempt to isolate this issue:


![image](https://github.com/user-attachments/assets/76e0140d-5221-4f4f-bbe8-8c20c6fa543f)
