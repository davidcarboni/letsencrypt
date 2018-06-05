#!/usr/bin/env bash

# Check we have a domain name for the cert:
if [ $# -eq 0 ]
  then
    echo "Please provide a domain name for the certificate."
    exit 1
fi

domain=$1
echo "Generating key and certificate signing request for: $domain"

openssl req -new -newkey rsa:4096 -nodes -sha256 -config /dev/stdin -keyout ${domain}.key -out ${domain}.csr <<CONF
[ req ]
x509_extensions = v3_req
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no
 
[ req_distinguished_name ]
countryName = GB
stateOrProvinceName = London
localityName = London
0.organizationName = Carboni Corporation
organizationalUnitName = Digital Technology
commonName = $domain
emailAddress = ca-admin@example.com
 
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
 
# all certificates now require a SAN field, even if there's only one host
subjectAltName = @alt_names
#
[ alt_names ]
DNS.1 = $domain
#add more if required
#DNS.2 = another.host.name
#...
 
CONF

# Check:
openssl req -noout -text -in ${domain}.csr -key ${domain}.key

