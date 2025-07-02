# ldapssltrusttest
Test LDAP SSL Trust via external java or internal JSP page


LDAPTLS_REQCERT=never ldapsearch -LLL -H ldaps://$(hostname):10101 -D 'cn=dsaadmin,ou=im,ou=ca,o=com' -w Password01! -s base
LDAPTLS_REQCERT=never ldapsearch -d9  -H ldaps://$(hostname):10101 -D 'cn=dsaadmin,ou=im,ou=ca,o=com' -w Password01! -s base

/opt/CA/java/bin/javac LdapSSLTrustTest.java

java -Djavax.net.debug=ssl:handshake:verbose:certpath:trustmanager LdapSSLTrustTest


![image](https://github.com/user-attachments/assets/d2fdfe63-3235-49fd-965a-6b4108853c55)


Attempt to isolate this issue within JXweb.    Note that a custom JSP page within the same context, has no issue.

![image](https://github.com/user-attachments/assets/74ad7f61-7b20-4176-a591-90566c79b112)


![image](https://github.com/user-attachments/assets/76e0140d-5221-4f4f-bbe8-8c20c6fa543f)


Issue appears to be tied to SSL context used in this jar.

C:\Program Files\CA\Directory\dxwebserver\webapps\jxweb\WEB-INF\lib

12/19/2016  01:47 PM           190,748 eTrust_Commons.jar
