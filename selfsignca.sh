#!/bin/bash

dedent() {
  local -n reference="$1"
  reference="$(echo "$reference" | sed 's/^[[:space:]]*//')"
}

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

text="authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
subjectAltName=@alt_names
[alt_names]
DNS.1=${domain}

"
  dedent text
  printf "$text" > $domain.ext

  openssl x509 -req -CA root_ca.crt -CAkey root_ca.key -in $domain.csr -out $domain.crt -days 365 -CAcreateserial -extfile $domain.ext

  rm $domain.csr $domain.ext
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
