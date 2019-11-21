#!/bin/bash

cd certs

echo "Generating Root CA Key"
openssl genrsa -out rootCA.key 4096

echo "Generating Root CA Certificate"
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1825 -subj "/C=IN/ST=Karnataka/L=Bangalore/O=Sarath Systems/OU=Research & Development/emailAddress=mekala.sarath@gmail.com/CN=Sarath Systems Digital Certification Authority" -out rootCA.pem

#echo "Converting Root CA PEM --> CRT"
openssl x509 -outform der -in rootCA.pem -out rootCA.crt

echo "Generating pkcsdemo Container's Private Key"
openssl genrsa -out server.key 4096

echo "Generating pkcsdemo Container's Certificate Signing Request"
openssl req -new -key server.key -subj "/C=IN/ST=Karnataka/L=Bangalore/O=Sarath Systems/OU=Research & Development/emailAddress=mekala.sarath@in.ibm.com/CN=Sarath Systems pkcsdemo server" -out server.csr

echo "Generating pkcsdemo Container's Certificate"
openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 1825 -sha256 -extfile cert.config

cp server.* rootCA.pem /usr/local/apache2/conf/

#Restart httpd
apachectl -k restart

tail -f /dev/null
