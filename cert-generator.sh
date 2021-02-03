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

# Set our CSR variables
SUBJ="
C=US
ST=NY
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

echo $SANAMES > san.ext

# Generate our Private Key, CSR and Certificate
openssl genrsa -out "$DOMAIN.key" 2048
openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key "$DOMAIN.key" -out "$DOMAIN.csr"
openssl x509 -req -days 3650 -in "$DOMAIN.csr" -signkey "$DOMAIN.key" -out "$DOMAIN.crt" -extfile san.ext

# Cleanup intermediate files
rm "$DOMAIN.csr"
rm san.ext

echo ""
echo "Next manual steps:"
echo "- Import $DOMAIN.crt and $DOMAIN.key during IEM portal installation"
