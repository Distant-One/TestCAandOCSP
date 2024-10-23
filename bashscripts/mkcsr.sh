#!/bin/bash
# File:
#   mkcsr.sh
# Description
#   Create Certificate Signing Request (CSR) for server authentication, client authentication, etc.
# Usage:
#   ./mkcsr.sh <name for cert> <path to key file, cnf file and where to put csr file>
# Example:
#   ./mkcsr.sh myserver ~/home/foo
# Depends on:
#   <idname>.key.pem - will create if not present
#   <idname>.cnf - config file for certificate request

idname=$1
dir=$2
keyfile="$idname.key.pem"
cnffile="$idname.cnf"
csrfile="$idname.csr.pem"
##### Generate key
echo "====== Generate key file"
if [ -f "$dir/$keyfile" ]
then
        echo "$dir/$keyfile exists."
else
# Maybe the following is for SSH certs
#       echo "ssh-keygen -t ecdsa -b 384 -f $dir/$keyfile"
#       ssh-keygen -t ecdsa -b 384 -f $dir/$keyfile
# The following is for 4096 rsa certs
#        echo "openssl genrsa -out $dir/$keyfile 4096"
#       openssl genrsa -out $dir/$keyfile 4096
# The following is for 2048 rsa certs
        echo "openssl genrsa -out $dir/$keyfile 2048"
        openssl genrsa -out $dir/$keyfile 2048
fi

##### Generate csr

echo "rm $dir/$csrfile"
rm $dir/$csrfile

echo "====== Generate CSR"
if [ -f "$dir/$csrfile" ]
then
        echo "$dir/$csrfile exists."
else
        echo "openssl req -new -key $dir/$keyfile -config $dir/$cnffile -out $dir/$csrfile"
        openssl req -new -key $dir/$keyfile -config $dir/$cnffile -out $dir/$csrfile


fi
echo "openssl req -in $dir/$csrfile -text -noout"
openssl req -in $dir/$csrfile -text -noout

