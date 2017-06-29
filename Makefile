REQ?=test

all:

RANDFILE=$(shell pwd)/db/rnd
export RANDFILE

SETTINGS:=$(shell readlink -e settings.mk)

ifeq ("$(SETTINGS)", "")
check-settings:
	@echo "Can't find settings.mk. Please copy it from settings.mk.template and update"
	exit 1
else
check-settings:
	@true

include $(SETTINGS)
endif


ca: check-settings init_ca ca/ClientCA.key ca/ClientCA.pem

init_ca:
	mkdir -p ca

ca/ClientCA.key:
	mkdir -p ca
	openssl genrsa -out $@ 2048

ca/ClientCA.pem: ca/ClientCA.key
	openssl req -x509 -new -nodes -key $< -days 7300 -subj $(CA_SUBJ) -out $@

dump_ca_cert:
	openssl x509 -in ca/ClientCA.pem -text -noout

sign: ca db
	openssl ca -batch -config ca.conf -name client_ca -notext -in $(REQ).csr -out $(REQ).cert
db:
	mkdir -p db certs
	echo 00 > db/serial
	touch db/certindex

protect:
	chmod 600 ca/ClientCA.key ca.conf

test-client: test.cert

test.key:
	openssl genrsa -out $@ 2048

test.csr: test.key
	openssl req -new -key test.key -nodes -subj /CN=test@example.com/emailAddress=test@example.com/ST=test/C=RU/O=test.example.com -out $@

test.cert: test.csr
	make REQ=test sign


backup:
	tar -cvf client_ca_backup_`date +%s`.tar ca db certs  req

.PHONY: protect