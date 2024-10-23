#!/bin/bash
## shell script to :
#       re-sign CA cert
#  used:
#	Re sign expired CA certs. Do not use for signing non-CA requests
#  usage:
#    ./re-signCA.sh int1CA rootCa /home/cienatest/CA/ca
#
# Note: If the CA structure was copied from anotehr server, replace the ipaddresses in the CA cnf files
#
##############################
caname=$1
signname=$2
cadir=$3
dir=$cadir/$caname
signdir=$cadir/$signname
ipserver=$4
echo "caname $caname"
echo "signname $signname"
echo "dir $dir"
echo "signdir $signdir"
echo "ipserver $ipserver"


#### make CA cert
echo "===== move old $caname.cert.pem  cert file ====="

echo "mv $dir/$caname.cert.pem $dir/old-$caname.cert.pem"
mv $dir/$caname.cert.pem $dir/old-$caname.cert.pem

echo "===== delete and touch $signdir/index.txt file ====="
echo "rm $signdir/index.txt"
rm $signdir/index.txt
echo "touch $signdir/index.txt"
touch $signdir/index.txt

##### Generate key
echo "====== Generate key file"
keyfile="$caname.key.pem"
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

echo "===== Creating $caname cert file ====="

if [ -f "$dir/$caname.cert.pem" ]
then
	echo "$dir/$caname.cert.pem exists"
else
	#### Generate rootCa cert
	if [ "$caname" = "rootCa" ]
	then
		echo "=== Generate rootCa cert"
		echo "openssl req -x509 -new -nodes -key $dir/$caname.key.pem -days 365 -out $dir/$caname.cert.pem -extensions v3_$caname -config $dir/$caname.cnf"
		openssl req -x509 -new -nodes -key $dir/$caname.key.pem -days 365 -out $dir/$caname.cert.pem -extensions v3_$caname -config $dir/$caname.cnf
		echo "=== Create cert chain file"
		echo "cp $dir/$caname.cert.pem $dir/Chain_$caname.cert.pem"
		cp $dir/$caname.cert.pem $dir/Chain_$caname.cert.pem
	else 
		echo "=== Generate $caname cert"
		echo "openssl req -config $dir/$caname.cnf -new -sha256 -key $dir/$caname.key.pem -out $dir/$caname.csr.pem"
		openssl req -config $dir/$caname.cnf -new -sha256 -key $dir/$caname.key.pem  -out $dir/$caname.csr.pem
                echo "=== Show CSR $caname CSR"
		echo "openssl req -in $dir/$caname.csr.pem -noout -text"
		openssl req -in $dir/$caname.csr.pem -noout -text
		echo "cp $dir/$caname.csr.pem $signdir/newcerts"
		cp $dir/$caname.csr.pem $signdir/newcerts
		echo "openssl ca -config $signdir/$signname.cnf -extensions v3_ocsp -days 365 -notext -md sha256 -in  $signdir/newcerts/$caname.csr.pem -out $signdir/newcerts/$caname.cert.pem"
		openssl ca -config $signdir/$signname.cnf -extensions v3_ocsp -days 365 -notext -md sha256 -in  $signdir/newcerts/$caname.csr.pem -out $signdir/newcerts/$caname.cert.pem
                echo "openssl x509 -in $signdir/newcerts/$caname.cert.pem -text -noout"
                openssl x509 -in $signdir/newcerts/$caname.cert.pem -text -noout
		echo "cp $signdir/newcerts/$caname.cert.pem $dir/"
		cp $signdir/newcerts/$caname.cert.pem $dir/
		echo "=== Create cert chain file"
		echo "cp $dir/$caname.cert.pem $dir/Chain_$caname.cert.pem"
		cp $dir/$caname.cert.pem $dir/Chain_$caname.cert.pem
		echo "cat $signdir/Chain_$signname.cert.pem >> $dir/Chain_$caname.cert.pem "
		cat $signdir/Chain_$signname.cert.pem >> $dir/Chain_$caname.cert.pem 

	fi
fi
echo "openssl x509 -in $dir/$caname.cert.pem -text -noout"
openssl x509 -in $dir/$caname.cert.pem -text -noout

