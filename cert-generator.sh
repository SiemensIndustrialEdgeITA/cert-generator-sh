#!/usr/bin/env bash

# print usage
DOMAIN=$1
if [ -z "$1" ]; then 

    echo "USAGE: $0 domain.lan"
    echo ""
    echo "This will generate a non-secure self-signed wildcard certificate for given domain."
    echo "This should only be used in a development environment."
    exit
fi

# Add wildcard
WILDCARD="*.$DOMAIN"

# Set our CSR variables
SUBJ="
C=US
ST=NY
O=Local Developement
localityName=Local Developement
commonName=$WILDCARD
organizationalUnitName=Local Developement
emailAddress=
"

# Generate our Private Key, CSR and Certificate
openssl genrsa -out "$DOMAIN.key" 2048
openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key "$DOMAIN.key" -out "$DOMAIN.csr"
openssl x509 -req -days 3650 -in "$DOMAIN.csr" -signkey "$DOMAIN.key" -out "$DOMAIN.crt"
rm "$DOMAIN.csr"

echo ""
echo "Next manual steps:"
echo "- Use $DOMAIN.crt and $DOMAIN.key to configure Apache/nginx"
echo "- Import $DOMAIN.crt into Chrome settings: chrome://settings/certificates > tab 'Authorities'"
