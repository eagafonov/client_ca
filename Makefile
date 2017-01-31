REQ?=test

all:

RANDFILE=$(shell pwd)/db/rnd
export RANDFILE


include settings.mk

ca: init_ca ca/ClientCA.key ca/ClientCA.pem

init_ca:
	mkdir -p ca

ca/ClientCA.key:
	mkdir -p ca
	openssl genrsa -out $@ 2048

ca/ClientCA.pem: ca/ClientCA.key
	openssl req -x509 -new -nodes -key $< -days 7300 -subj $(CA_SUBJ) -out $@

dump_ca_cert:
	openssl x509 -in ca/ClientCA.pem -text -noout

sign: db ca
	openssl ca -batch -config ca.conf -name client_ca -notext -in $(REQ).csr -out $(REQ).cert
db:
	mkdir -p db certs
	echo 00 > db/serial
	touch db/certindex

protect:
	chmod 600 ca/ClientCA.key ca.cnf

.PHONY: protect