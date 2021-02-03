#!/usr/bin/env bash

# print usage
DOMAIN=$1
if [ -z "$1" ]; then 

    printf  "Industrial Edge Management cert-generator-sh\n"
    printf  "\n"
    printf  "USAGE: $0 domain.com\n"
    printf  "\n"
    printf  "This will generate a 10yr valid self-signed certificate for given <domain.com>. \nWith subdomains: \nportal.<domain.com> \nhub.<domain.com> \nrelay.<domain.com>\n"
    printf  ""
    exit
fi

# Add wildcard
#DOMAIN="*.$DOMAIN"

# Subj alternative names
SAN=DNS:$DOMAIN, DNS:portal.$DOMAIN, DNS:hub.$DOMAIN, DNS:relay.$DOMAIN

# Set our IEM CSR variables
RCASUBJ="
C=IT
ST=Italy
O=siemens
localityName=Italy
commonName=rootCA
organizationalUnitName=siemens
emailAddress=
"
# Set our IEM CSR variables
IEMSUBJ="
C=IT
ST=Italy
O=Local Developement
localityName=Local Developement
commonName=$DOMAIN
organizationalUnitName=Local Developement
emailAddress=
"
# Our alternative names
SANAMES="subjectAltName = 	\
DNS:$DOMAIN, 			\
DNS:portal.$DOMAIN, 		\
DNS:hub.$DOMAIN, 		\
DNS:relay.$DOMAIN" 

# Write to extesion file
echo $SANAMES > san.ext

# Generate rootCA private key 
openssl genrsa -out rootCA.key 2048

# Generate selfsigned rootCA cert
openssl req -x509 -new -subj "$(echo -n "$RCASUBJ" | tr "\n" "/")" -nodes -key rootCA.key -sha256 -days 3650 -out rootCA.crt

# Generate iem key
openssl genrsa -out "$DOMAIN.key" 2048

# Generate iem csr request 
openssl req -new -subj "$(echo -n "$IEMSUBJ" | tr "\n" "/")" -key "$DOMAIN.key" -out "$DOMAIN.csr"

# Generate iem crt file
#openssl x509 -req -days 3650 -in "$DOMAIN.csr" -signkey "$DOMAIN.key" -out "$DOMAIN.crt" -extfile san.ext
openssl x509 -req -days 3650 -in "$DOMAIN.csr" -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out "$DOMAIN.crt" -extfile san.ext

# Cleanup intermediate files
rm "$DOMAIN.csr"
rm san.ext
rm rootCA.srl

echo ""
echo "Next manual steps:"
echo "- Import $DOMAIN.crt and $DOMAIN.key during IEM portal installation"
