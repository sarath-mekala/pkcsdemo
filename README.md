# PKCS (Private Root CA + Signed Private Certificates)

This container is a POC to understand the process of generating your own Private Root CA and then signing your own digital certificates.

The project has the following structure:
├── certs
│   └── cert.config
├── conf
│   ├── httpd.conf
│   └── httpd-ssl.conf
├── Dockerfile
├── entrypoint.sh
├── LICENSE
├── public-html
│   └── index.html
└── README.md

* Dockerfile : Contains the commands to make the docker image
* entrypoint.sh : startup script which does the following:
  * Generates Root CA (Public + Private Key)
  * Generates Server Certificates (Public + Private Key)
  * Generates a CSR (Certificate Signing Request)
  * Signs the Server Certificates with the RootCA certificate.
  
RFC 2818 describes two methods to match a domain name against a certificate:
* subjectAlternativeName
* commonName

Since 2000 the support for commonName has been dropped by most of the browsers <https://www.chromestatus.com/features/4981025180483584>

* cert.config : is used to define the subjectAlternativeName and related configuration.

```authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 =  www.pkcsdemo.com
IP.1 = 192.168.56.101
```

Here DNS.1 = www.pkcsdemo.com is one DNS alternative name we are supplying to the certificate. Similarly, you can give more DNS alt names via DNS.2, DNS.3 e.t.c
IP.1 = 192.168.56.101 is the IP address that I am binding to the certificate. **You should alter it based on your setup.**

