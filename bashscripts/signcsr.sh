#!/bin/bash
configfile=$1
csrname=$2
certname=$3
echo "openssl ca -config $configfile -extensions v3_ocsp -days 365 -notext -md sha256 -in $csrname -out $certname"
openssl ca -config $configfile -extensions v3_ocsp -days 365 -notext -md sha256 -in $csrname -out $certname
echo "Display certificate"
echo "openssl x509 -in $certname -text -noout"
openssl x509 -in $certname -text -noout


