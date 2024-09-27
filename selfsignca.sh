#!/bin/bash

function create_ca_cert() {
  echo -e "[/] Certification Center Certificate not found. Creating..."
  echo -e "Enter Name"
  read ca_name

  openssl req -subj "/CN=${ca_name}" -nodes -x509 -sha256 -days 3653 -newkey rsa:2048 -keyout root_ca.key -out root_ca.crt &>/dev/null
  echo -e "[+] Certification Center Certificate Created"
}

function sign_cert() {
  read -p "Enter a domain: " domain
  openssl genrsa -out $domain.key 2048

  openssl req -new -subj "/CN=${domain}" -key $domain.key -out $domain.csr

  openssl x509 -req -CA root_ca.crt -CAkey root_ca.key -in $domain.csr -out $domain.crt -days 365 -CAcreateserial

  rm $domain.csr
  echo -e "[+] Created cert files: ${domain}.crt ${domain}.key"
}

# Main frgment


echo "Welcome to selfsignca util"
echo ""

if [ -e "root_ca.key" ]; then
  sign_cert
else
  create_ca_cert
  sign_cert
fi

echo "[+] Done"
