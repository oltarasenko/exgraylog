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

generate-certs:
	openssl genrsa -out /tmp/root.key 1024
	openssl req -new -x509 -days 1826 -key /tmp/root.key -out /tmp/root.crt
	openssl genrsa -out /tmp/private.key 1024
	openssl req -new -key /tmp/private.key -out /tmp/private.csr
	openssl x509 -req -days 730 -in /tmp/private.csr -CA /tmp/root.crt -CAkey /tmp/root.key -set_serial 01 -out /tmp/private.crt




