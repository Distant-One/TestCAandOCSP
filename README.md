# TestCAandOCSP

Ansible based repo to Create CA and OCSP Testing environment for x.509 certificates



Previous README.md from bash scripted version is below:

Create CA and OCSP Testing environment for x.509 certificates

You'll need:
Linux Server (Raspberry Pi 3 or 4 works)

You need to create the following:
Local DNS server (Bind) - For case where certificate IP Address as common name is not allowed, i.e. DNS is required
RootCA self signed (CA1)
1st Intermediate CA signed by rootCA (CA2)
2nd Intermediate CA signed by Intermediate CA2 (CA3)
2nd False Intermediate CA signed by Intermediate CA2 (CA4) - Has CA constraint set to false - installing/receiving certs signed with false CA constraint shall fail
2nd Missing Intermediate CA signed by Intermediate CA2 (CA5) - Has CA constraint missing - installing/receiving certs signed with no CA constraint shall fail

Certificate signing constraints for the following:
Certificate Authority Certs
server certs
client certs
codeSigning
digitalSignature
bad SAN
bad OCSP address

Insructions for installing all CA's and OCSP servers on the same server

1. Set up CA info 
	CA Names
	  CA1=rootCA
	  CA2=int2CA
	  CA3=int2CA
          CA4=falseCA
	  CA5=missingCA
	CA info
	  CACountry=CertCountry
	  CAState=CertState
	  CALocal=CertCity
	  CAOrganization=CertCompany
	  CAOrgUnit=CertGroup
	  CAEmail=$CA@no.where

	CA IP Address
	  CAIPaddress = $(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
	  if $CA=$CA1
	    CAOCSPIPAddress = "$CAIPaddress:8880"
	  elseif $CA=$CA2
	    CAOCSPIPAddress = "$CAIPaddress:8881"
	  else 
	    CAOCSPIPAddress = "$CAIPaddress:8882"
	    BADOCSPIPAddress = "10.10.10.10"8882"
          endif
2. Create file structure for CA1-CA5
	get root PWD for the CA directories
	  CAPWD=$PWD/$CA
	for CA1, CA2, CA3, CA4 and CA5
	  mkdir $CAPWD/$CA
	  generate private/public key to $CAPWD/$CA.key.pem
	  mkdir $CAPWD/newcerts
	  touch $CAPWD/index.txt
	  touch $CAPWD/index.txt.attr
	  echo 1000 > $CAPWD/serial
	end for
3. Create config file for CA1-CA5
	set ca config file name
	for CA1 - CA5
	  CAConfigFile="$CA.cnf"
	  echo "#Config file for $CA" > $CAPWD/$CAConfigFile
	  echo "#Begin OpenSSL CA Config  " >> $CAPWD/$CAConfigFile
	  echo " " >> $CAPWD/$CAConfigFile
	  echo "[ ca ]" >> $CAPWD/$CAConfigFile
	  echo "default_ca = CA_default" >> $CAPWD/$CAConfigFile
	  echo "" >> $CAPWD/$CAConfigFile
	  echo "[ CA_default ]" >> $CAPWD/$CAConfigFile
	  echo "#this is the directory where the CA cert will live" >> $CAPWD/$CAConfigFile
	  echo "dir = $CAPWD/$CA" >> $CAPWD/$CAConfigFile
	  echo "" >> $CAPWD/$CAConfigFile
	  echo "#where the newcerts will be copied to be tracked" >> $CAPWD/$CAConfigFile
	  echo "new_certs_dir = $CAPWD/newcerts" >> $CAPWD/$CAConfigFile
	  echo "" >> $CAPWD/$CAConfigFile
	  echo "#the database file that tracks the status of certs" >> $CAPWD/$CAConfigFile
	  echo "database = $CAPWD/index.txt" >> $CAPWD/$CAConfigFile
	  echo "" >> $CAPWD/$CAConfigFile
	  echo "#the serial number to place on a signed cert" >> $CAPWD/$CAConfigFile
	  echo "serial = $CAPWD/serial" >> $CAPWD/$CAConfigFile
	  echo "" >> $CAPWD/$CAConfigFile
	  echo "#the CA cert's private key" >> $CAPWD/$CAConfigFile
	  echo "private_key = $CAPWD/$CA.key.pem" >> $CAPWD/$CAConfigFile
	  echo "" >> $CAPWD/$CAConfigFile
	  echo "#the CA cert's certificate" >> $CAPWD/$CAConfigFile
	  echo "certificate = $CAPWD/$CA.cert.pem" >> $CAPWD/$CAConfigFile
	  echo "" >> $CAPWD/$CAConfigFile
	  echo "#the default message digest algorithm" >> $CAPWD/$CAConfigFile
	  echo "default_md = sha256" >> $CAPWD/$CAConfigFile
	  echo "" >> $CAPWD/$CAConfigFile
	  echo "#default number of days for a cert to be valid" >> $CAPWD/$CAConfigFile
	  echo "default_days = 365" >> $CAPWD/$CAConfigFile
	  echo "  " >> $CAPWD/$CAConfigFile
	  echo " #formatting for certificate display, leave as default" >> $CAPWD/$CAConfigFile
	  echo "name_opt = ca_default" >> $CAPWD/$CAConfigFile
	  echo "cert_opt = ca_default" >> $CAPWD/$CAConfigFile
	  echo " " >> $CAPWD/$CAConfigFile
	  echo "#preserve ordering of requests, leave as no as it's largely for older versions of OpenSSL" >> $CAPWD/$CAConfigFile
	  echo "preserve = no" >> $CAPWD/$CAConfigFile
	  echo " " >> $CAPWD/$CAConfigFile
	  echo "#if signing a certificate has some requirements, e.g. can only sign certs from the same country" >> $CAPWD/$CAConfigFile
	  echo "policy = policy_loose" >> $CAPWD/$CAConfigFile
	  echo " " >> $CAPWD/$CAConfigFile
	  echo "#can be either optional, supplied, or match" >> $CAPWD/$CAConfigFile
	  echo "[ policy_loose ]" >> $CAPWD/$CAConfigFile
	  echo "countryName            = optional" >> $CAPWD/$CAConfigFile
	  echo "stateOrProvinceName    = optional" >> $CAPWD/$CAConfigFile
	  echo "localityName           = optional" >> $CAPWD/$CAConfigFile
	  echo "organizationName       = optional" >> $CAPWD/$CAConfigFile
	  echo "organizationalUnitName = optional" >> $CAPWD/$CAConfigFile
	  echo "commonName             = supplied" >> $CAPWD/$CAConfigFile
	  echo "emailAddress           = optional" >> $CAPWD/$CAConfigFile
	  echo "" >> $CAPWD/$CAConfigFile
	  echo "#auto populate various attributes for the openssl req command" >> $CAPWD/$CAConfigFile
	  echo "[ req ]" >> $CAPWD/$CAConfigFile
	  echo "prompt = no" >> $CAPWD/$CAConfigFile
	  echo "distinguished_name = req_distinguished_name" >> $CAPWD/$CAConfigFile
	  echo "# commented this line out so that it could be set in next line req_extensions = v3_ca" >> $CAPWD/$CAConfigFile
	  echo "#req_extensions = v3_ca" >> $CAPWD/$CAConfigFile
	  echo "#_rq _eqls _vlu" >> $CAPWD/$CAConfigFile
	  echo "[ req_distinguished_name ]" >> $CAPWD/$CAConfigFile
	  echo "#follows the ordering from policy_loose above" >> $CAPWD/$CAConfigFile
	  echo "C  = $CACountry" >> $CAPWD/$CAConfigFile
	  echo "ST = $CALocal" >> $CAPWD/$CAConfigFile
	  echo "L  = $CAOrganization" >> $CAPWD/$CAConfigFile
	  echo "O  = $CAOrganization" >> $CAPWD/$CAConfigFile
	  echo "OU = $CAOrgUnit" >> $CAPWD/$CAConfigFile
	  echo "CN = $CA" >> $CAPWD/$CAConfigFile
	  echo "emailAddress = int2CA@no.where" >> $CAPWD/$CAConfigFile
	    echo "#constraints used to self sign root CA - not sure if this is used for in CA2-CA5" >> $CAPWD/$CAConfigFile
	    echo "[ v3_ca ]" >> $CAPWD/$CAConfigFile
	  if $CA=$CA1
	    echo "basicConstraints        = critical, CA:true, pathlen:3" >> $CAPWD/$CAConfigFile
	  if $CA=$CA2
	    echo "basicConstraints        = critical, CA:true, pathlen:2" >> $CAPWD/$CAConfigFile
	  if $CA=$CA3
	    echo "basicConstraints        = critical, CA:true, pathlen:1" >> $CAPWD/$CAConfigFile
	  if $CA=$CA4 #CA False
	    echo "basicConstraints        = critical, CA:false, pathlen:1" >> $CAPWD/$CAConfigFile
	  if $CA=$CA5 #CA Misssing
	    echo "#basicConstraints        = critical, CA:true, pathlen:1" >> $CAPWD/$CAConfigFile
	  endif
	    echo "subjectKeyIdentifier   = hash" >> $CAPWD/$CAConfigFile
	    echo "authorityKeyIdentifier = keyid:always,issuer" >> $CAPWD/$CAConfigFile
	    echo "authorityInfoAccess    = OCSP;URI:http://$CAOCSPIPAddress" >> $CAPWD/$CAConfigFile
	    echo "extendedKeyUsage        = clientAuth, serverAuth" >> $CAPWD/$CAConfigFile
	    echo "#extendedKeyUsage       = serverAuth" >> $CAPWD/$CAConfigFile
	    echo "keyUsage                = critical, digitalSignature, cRLSign, keyCertSign" >> $CAPWD/$CAConfigFile
	    echo " " >> $CAPWD/$CAConfigFile
	    echo "#constraints used to sign following intermediate CA" >> $CAPWD/$CAConfigFile
	    echo "[ v3_intermediate_ca ]" >> $CAPWD/$CAConfigFile
	  if $CA=$CA1
	    echo "basicConstraints        = critical, CA:true, pathlen:2" >> $CAPWD/$CAConfigFile
	  if $CA=$CA2
	    echo "basicConstraints        = critical, CA:true, pathlen:1" >> $CAPWD/$CAConfigFile
	  if $CA=$CA3
	    echo "basicConstraints        = critical, CA:true, pathlen:0" >> $CAPWD/$CAConfigFile
	  if $CA=$CA4 #False intermediate CA
	    echo "basicConstraints        = critical, CA:false, pathlen:0" >> $CAPWD/$CAConfigFile
	  if $CA=$CA5 #Missing intermediate CA
	    echo "#basicConstraints        = critical, CA:true, pathlen:0" >> $CAPWD/$CAConfigFile
	  endif
	    echo "subjectKeyIdentifier   = hash" >> $CAPWD/$CAConfigFile
	    echo "authorityKeyIdentifier = keyid:always,issuer" >> $CAPWD/$CAConfigFile
	    echo "authorityInfoAccess    = OCSP;URI:http://$CAOCSPIPAddress" >> $CAPWD/$CAConfigFile
	    echo "extendedKeyUsage        = clientAuth, serverAuth" >> $CAPWD/$CAConfigFile
	    echo "#extendedKeyUsage        = serverAuth" >> $CAPWD/$CAConfigFile
	    echo "keyUsage                = critical, digitalSignature, cRLSign, keyCertSign" >> $CAPWD/$CAConfigFile
	    echo " " >> $CAPWD/$CAConfigFile
	  if $CA=$CA2 # 1st Intermediate CA
	    echo "#added for int2CAFalse" >> $CAPWD/$CAConfigFile
	    echo "[ v3_int2CAFalse_ca ]" >> $CAPWD/$CAConfigFile
	    echo "basicConstraints        = critical, CA:false, pathlen:1" >> $CAPWD/$CAConfigFile
	    echo "subjectKeyIdentifier   = hash" >> $CAPWD/$CAConfigFile
	    echo "authorityKeyIdentifier = keyid:always,issuer" >> $CAPWD/$CAConfigFile
	    echo "authorityInfoAccess    = OCSP;URI:http://$CAOCSPIPAddress" >> $CAPWD/$CAConfigFile
	    echo "extendedKeyUsage        = clientAuth, serverAuth" >> $CAPWD/$CAConfigFile
	    echo "#extendedKeyUsage        = serverAuth" >> $CAPWD/$CAConfigFile
	    echo "keyUsage                = critical, digitalSignature, cRLSign, keyCertSign" >> $CAPWD/$CAConfigFile
	    echo " " >> $CAPWD/$CAConfigFile
	    echo "#added for int2CAMissing" >> $CAPWD/$CAConfigFile
	    echo "[ v3_int2CAMissing_ca ]" >> $CAPWD/$CAConfigFile
	    echo "#basicConstraints        = critical, CA:false, pathlen:1" >> $CAPWD/$CAConfigFile
	    echo "subjectKeyIdentifier   = hash" >> $CAPWD/$CAConfigFile
	    echo "authorityKeyIdentifier = keyid:always,issuer" >> $CAPWD/$CAConfigFile
	    echo "authorityInfoAccess    = OCSP;URI:http//$CAOCSPIPAddress" >> $CAPWD/$CAConfigFile
	    echo "extendedKeyUsage        = clientAuth, serverAuth" >> $CAPWD/$CAConfigFile
	    echo "#extendedKeyUsage        = serverAuth" >> $CAPWD/$CAConfigFile
	    echo "keyUsage                = critical, digitalSignature, cRLSign, keyCertSign" >> $CAPWD/$CAConfigFile
	    echo " " >> $CAPWD/$CAConfigFile
	  elif $CA=$CA3 #2nd Intermediate CA
	    echo "#Extensions for signing server cert requests" >> $CAPWD/$CAConfigFile
	    echo "#[ server ]" >> $CAPWD/$CAConfigFile
	    echo "basicConstraints        = CA:FALSE" >> $CAPWD/$CAConfigFile
	    echo "subjectKeyIdentifier   = hash" >> $CAPWD/$CAConfigFile
	    echo "authorityKeyIdentifier = keyid,issuer:always" >> $CAPWD/$CAConfigFile
	    echo "#this contains the URL to send an ocsp request to" >> $CAPWD/$CAConfigFile
	    echo "authorityInfoAccess    = OCSP;URI:http://$CAOCSPIPAddress" >> $CAPWD/$CAConfigFile
	    echo "extendedKeyUsage        = serverAuth" >> $CAPWD/$CAConfigFile
	    echo "subjectAltName  = @alt_names" >> $CAPWD/$CAConfigFile
	    echo "" >> $CAPWD/$CAConfigFile
	    echo "#Extensions for signing server cert with bad ocsp address" >> $CAPWD/$CAConfigFile
	    echo "#[ server ]" >> $CAPWD/$CAConfigFile
	    echo "basicConstraints        = CA:FALSE" >> $CAPWD/$CAConfigFile
	    echo "subjectKeyIdentifier   = hash" >> $CAPWD/$CAConfigFile
	    echo "authorityKeyIdentifier = keyid,issuer:always" >> $CAPWD/$CAConfigFile
	    echo "#this contains the URL to send an ocsp request to" >> $CAPWD/$CAConfigFile
	    echo "authorityInfoAccess    = OCSP;URI:http://$BADOCSPIPAddress" >> $CAPWD/$CAConfigFile
	    echo "extendedKeyUsage        = serverAuth" >> $CAPWD/$CAConfigFile
	    echo "subjectAltName  = @alt_names" >> $CAPWD/$CAConfigFile
	    echo "" >> $CAPWD/$CAConfigFile
	    echo "#the extensions we give to client certs we sign" >> $CAPWD/$CAConfigFile
	    echo "[ client ]" >> $CAPWD/$CAConfigFile
	    echo "basicConstraints        = CA:FALSE" >> $CAPWD/$CAConfigFile
	    echo "subjectKeyIdentifier   = hash" >> $CAPWD/$CAConfigFile
	    echo "authorityKeyIdentifier = keyid,issuer:always" >> $CAPWD/$CAConfigFile
	    echo "#this contains the URL to send an ocsp request to" >> $CAPWD/$CAConfigFile
	    echo "authorityInfoAccess    = OCSP;URI:http://$CAOCSPIPAddress" >> $CAPWD/$CAConfigFile
	    echo "extendedKeyUsage        = clientAuth" >> $CAPWD/$CAConfigFile
	    echo "keyUsage        =       nonRepudiation, digitalSignature, keyEncipherment" >> $CAPWD/$CAConfigFile
	    echo "" >> $CAPWD/$CAConfigFile
	    echo "" >> $CAPWD/$CAConfigFile
	    echo "#the extensions we give to software signing certs we sign" >> $CAPWD/$CAConfigFile
	    echo "[ softsigning_ocsp ]" >> $CAPWD/$CAConfigFile
	    echo "basicConstraints        = CA:FALSE" >> $CAPWD/$CAConfigFile
	    echo "subjectKeyIdentifier   = hash" >> $CAPWD/$CAConfigFile
	    echo "authorityKeyIdentifier = keyid,issuer:always" >> $CAPWD/$CAConfigFile
	    echo "#this contains the URL to send an ocsp request to" >> $CAPWD/$CAConfigFile
	    echo "authorityInfoAccess    = OCSP;URI:http:$CAOCSPIPAddress" >> $CAPWD/$CAConfigFile
	    echo "extendedKeyUsage       = codeSigning" >> $CAPWD/$CAConfigFile
	    echo "keyUsage        =       digitalSignature" >> $CAPWD/$CAConfigFile
	    echo "" >> $CAPWD/$CAConfigFile
	    echo "# List of alternetive names for generating certs - generate a cert for each of the items in the list - some will be Bad SAN's" >> $CAPWD/$CAConfigFile
	    echo "[ alt_names ]" >> $CAPWD/$CAConfigFile
	    echo "#DNS.1  =       bad.$CAOrganization.local" >> $CAPWD/$CAConfigFile
	    echo "#DNS.1  =       SFTP-Server.$CAOrganization.local" >> $CAPWD/$CAConfigFile
	    echo "#DNS.1  =       Syslog-Server.$CAOrganization.local" >> $CAPWD/$CAConfigFile
	    echo "#DNS.1  =       RADSEC-Server.$CAOrganization.local" >> $CAPWD/$CAConfigFile
	    echo "#DNS.1  =       *.$CAOrganization.local" >> $CAPWD/$CAConfigFile
	    echo "#DNS.1  =       foo.*.$CAOrganization.local" >> $CAPWD/$CAConfigFile
	    echo "#IP.1   =       192.168.2.101	#This ipaddress needs to match the server or client of the certificate signing request" >> $CAPWD/$CAConfigFile
	endif
	  echo "#End OpenSSL CA Config" >> $CAPWD/$CAConfigFile


