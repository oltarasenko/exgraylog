ifeq (,$(wildcard config/dev_local.config))
CONFIG := config/dev.config
else
CONFIG := config/dev_local.config
endif

devel:
	@echo $(CONFIG)
	@ERL_LIBS=_build/dev/lib/ iex --name exgraylog@127.0.0.1 \
		--erl "+K true" \
		-S mix

clean:
	@mix clean


deps:
	@mix deps.get
	@mix deps.compile

graylog:
	sudo docker-compose up graylog

CERTS_DIR := /tmp/certs

generate-certs:
	mkdir -p $(CERTS_DIR)

	echo "Generating server key/cert"
	# Self signed root certificate
	openssl genrsa -out $(CERTS_DIR)/ca.key 1024
	openssl req -new -x509 -days 1826 -key $(CERTS_DIR)/ca.key -out $(CERTS_DIR)/ca.crt

	openssl genrsa -out $(CERTS_DIR)/app.key 1024
	
	# Convert key to PKCS#8 in DER format (this is what graylog expects)
	openssl pkcs8 -outform DER -in $(CERTS_DIR)/app.key -topk8 -nocrypt -out $(CERTS_DIR)/app.pkcs8

	# Make csr request
	openssl req -subj "/CN=example.com" -sha256 -new -key $(CERTS_DIR)/app.key -out $(CERTS_DIR)/app.csr

	# Sign csr with CA
	echo subjectAltName = DNS:*,IP:127.0.0.1 > $(CERTS_DIR)/extfile.cnf
	openssl x509 -req -days 3652 -sha256 \
		-CA $(CERTS_DIR)/ca.crt -CAkey $(CERTS_DIR)/ca.key \
		-CAcreateserial -extfile $(CERTS_DIR)/extfile.cnf \
		-in $(CERTS_DIR)/app.csr -out $(CERTS_DIR)/app.crt

	# In the input configuration please use like this:

 	# TLS cert file: app.crt
 	# TLS private key file: app.pkcs8
 	# Enable TLS: true
 	# TLS Client Auth Trusted Certs: ca.crt
 	# TLS client authentication: required

	# openssl genrsa -out $(CERTS_DIR)/private.key 1024
	# openssl req -new -key $(CERTS_DIR)/private.key -out $(CERTS_DIR)/private.csr
	# openssl x509 -req -days 730 -in $(CERTS_DIR)/private.csr -CA $(CERTS_DIR)/root.crt -CAkey $(CERTS_DIR)/root.key -set_serial 01 -out $(CERTS_DIR)/private.crt

	echo "Generating client key/certs"
	openssl genrsa -out $(CERTS_DIR)/client.key 1024

	# Create Cert signing request
	openssl req -subj "/CN=example.com" -sha256 -new -key $(CERTS_DIR)/client.key -out $(CERTS_DIR)/client.csr

	# Sign csr with CA
	echo extendedKeyUsage = clientAuth > $(CERTS_DIR)/extfile.cnf
	openssl x509 -req -days 3652 -sha256 -CA $(CERTS_DIR)/ca.crt -CAkey $(CERTS_DIR)/ca.key\
		-CAcreateserial -extfile $(CERTS_DIR)/extfile.cnf\
		-in $(CERTS_DIR)/client.csr -out $(CERTS_DIR)/client.crt

	# Now clients must use project.key and project.crt during TLS connection.


