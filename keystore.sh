#!/bin/bash

# ---- CONFIG ----
host="192.168.2.21"
port="10101"
keystore="keystore.jks"
storepass="changeit"
alias1="dxcert_${host}_${port}_1"
alias2="dxcert_${host}_${port}_2"
leaf_cert="/opt/CA/Directory/dxserver/config/ssld/personalities/dev-userstore_userstore-01.pem"
ca_cert="/opt/CA/Directory/dxserver/config/ssld/trusted.pem"
keytool="/opt/CA/java/bin/keytool"


# ---- DELETE EXISTING KEYSTORE ----
if [ -f "$keystore" ]; then
  echo "[*] Deleting existing keystore: $keystore"
  rm -f "$keystore"
fi

# ---- IMPORT NEW PERSONALITY CERT ----
echo "[*] Importing new leaf (personality) certificate..."
$keytool -import -noprompt -alias "$alias1" -file "$leaf_cert" -keystore "$keystore" -storepass "$storepass"

# ---- IMPORT TRUSTED ROOT CA CERT ----
echo "[*] Importing trusted root CA certificate..."
$keytool -import -noprompt -trustcacerts -alias "$alias2" -file "$ca_cert" -keystore "$keystore" -storepass "$storepass"

# ---- VERIFY RESULTS ----
echo -e "\n[*] Certificates in keystore '$keystore':"
$keytool -list -v -keystore "$keystore" -storepass "$storepass" | grep -E "Alias name|Owner|Issuer|Valid from|until|SHA256"


########################################

alias1="dxcert_${host}_${port}_3"
alias2="dxcert_${host}_${port}_4"
leaf_cert="/opt/CA/Directory/dxserver/config/ssld/personalities/dev-ca-prov-srv-01-imps-router.pem"
ca_cert="/opt/CA/Directory/dxserver/config/ssld/impd_trusted.pem"


# ---- IMPORT NEW CERTIFICATES ----
echo "[*] Importing new personality certificate..."
$keytool -import -noprompt -alias "$alias1" -file "$leaf_cert" -keystore "$keystore" -storepass "$storepass"

echo "[*] Importing trusted root CA certificate..."
$keytool -import -noprompt -trustcacerts -alias "$alias2" -file "$ca_cert" -keystore "$keystore" -storepass "$storepass"

# ---- VERIFY RESULTS ----
echo -e "\n[*] Certificates in keystore '$keystore':"
$keytool -list -v -keystore "$keystore" -storepass "$storepass" | grep -E "Alias name|Owner|Issuer|Valid from|until|SHA256"

