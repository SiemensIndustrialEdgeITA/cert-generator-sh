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


# Create certs folder
mkdir -p ./certs

# Write to extesion file
echo $SANAMES > certs/san.ext

# Generate rootCA private key 
openssl genrsa -out certs/rootCA.key 2048

# Generate selfsigned rootCA cert
openssl req -x509 -new -subj "$(echo -n "$RCASUBJ" | tr "\n" "/")" -nodes -key certs/rootCA.key -sha256 -days 3650 -out certs/rootCA.crt

# Generate iem key
openssl genrsa -out certs/$DOMAIN.key 2048

# Generate iem csr request 
openssl req -new -subj "$(echo -n "$IEMSUBJ" | tr "\n" "/")" -key certs/$DOMAIN.key -out certs/$DOMAIN.csr

# Generate iem crt file
#openssl x509 -req -days 3650 -in "$DOMAIN.csr" -signkey "$DOMAIN.key" -out "$DOMAIN.crt" -extfile san.ext
openssl x509 -req -days 3650 -in certs/$DOMAIN.csr -CA certs/rootCA.crt -CAkey certs/rootCA.key -CAcreateserial -out certs/$DOMAIN.crt -extfile certs/san.ext

# Cascade rootCA iem certs
cp certs/$DOMAIN.crt certs/$DOMAIN-cascade.crt && cat certs/rootCA.crt >> certs/$DOMAIN-cascade.crt

# Cleanup intermediate files
rm certs/$DOMAIN.csr
rm certs/san.ext
rm certs/rootCA.srl

# Cleanup unused files
rm certs/rootCA.crt
rm certs/$DOMAIN.crt 
rm certs/rootCA.key

echo ""
echo "Next manual steps:"
echo "- Import certs/$DOMAIN.crt and certs/$DOMAIN.key during IEM portal installation"
