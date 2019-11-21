FROM httpd:2.4

#Install necessary software
RUN apt-get update && apt-get install openssl
# Configure httpd
COPY ./public-html/ /usr/local/apache2/htdocs/
COPY ./conf/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY ./conf/httpd-ssl.conf /usr/local/apache2/conf/extra/httpd-ssl.conf

# Entrypoint
COPY ./certs /certs
COPY ./entrypoint.sh /

WORKDIR /
ENTRYPOINT ["/entrypoint.sh"]
