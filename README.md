# PKCS (Private Root CA + Signed Private Certificates)

This project demonstrates the process of generating your own Private Root CA and then signing your digital certificates with it. It generates a docker container using httpd:2.4 images as the base, which can then be deployed and tested.

## Prerequisites
* Docker

The project has the following structure:
```
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
```
* Dockerfile : Contains the commands to make the docker image
* public-html : folder consists of web application files. In the case of this POC, it has index.html file in it.
* conf : this folder has the httpd:2.4 related configuration. It will be explained in detail further below.
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


## Configuring HTTPD
The docker image is based on httpd:2.4 and it enables us to quickly configure a httpd server and test our certificates with it. Two files are used to configure httpd server: httpd.conf, httpd-ssl.conf

### httpd.conf
The following changes are done in this file:
```
* ServerRoot "/usr/local/apache2"
* DocumentRoot "/usr/local/apache2/htdocs"  (from host copy public-html folder here)

#### To enable SSL/HTTPS
The generated certificates should get copied to /usr/local/apache2/conf/ and httpd.conf 
should be configured to pick them from this location. The POC copies the following certificates 
to this location:
 * server.crt
 * server.key

In addition, enable the following lines:
 * LoadModule ssl_module modules/mod_ssl.so
 * LoadModule socache_shmcb_module modules/mod_socache_shmcb.so
 * Include conf/extra/httpd-ssl.conf

```
### httpd-ssl.conf
```
ServerName www.pkcsdemo.com:443
ServerAdmin mekala.sarath@gmail.com
SSLCertificateFile "/usr/local/apache2/conf/server.crt"
SSLCertificateKeyFile "/usr/local/apache2/conf/server.key"
```

Once the configuration is done, entrypoint.sh restarts the httpd server using:
> apachectl -k restart

## Deploying the image
Once you clone this project, go to its root folder and do the following to build and deploy the image:
* docker build -t pkcsdemo .
* docker run -d -p 8080:80 -p 8443:443 --name pkcsdemo pkcsdemo

> -p 8080:80 : port maps the host machines 8080 port to the container's 80 port
> -p 8443:443 : port maps the host machines 8443 port to the container's 443 port

## Configuring Firefox/Chrome with the RootCA certificate
In order to validate the signed server certificates sent by the demo container during SSL handshake, the browser needs to have the RootCA certificate registered with it.
* Extract the RootCA from the container
> docker cp <container_name or id>:/certs/rootCA.crt .

### Firefox
* Goto Preferences -> Privacy & Security -> Certificates (section) -> Click on 'View Certificates'
* Goto Authorities tab and click on 'Import' and select the rootCA.crt file

### Chrome
* Goto Settings -> Advanced -> Privacy & Security -> Authorities -> Click on 'Import' and select the rootCA.crt file.
