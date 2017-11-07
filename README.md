# Exgraylog

Elixir graylog transport, which allows to send messages in GELF format.
Also has an option to intersect all logging messages (from Logger and :error_logger) and to send them to Gralog.

Support two protocols for now (TCP and SSL)

## Configuration

### Bringing up graylog locally

In order to bring up graylog locally you need to have docker and docker-compose installed on your system. See more details here: https://docs.docker.com/engine/installation/

Once you have docker installed, you can bring up graylog locally:
```makefile
make graylog
```

Once it will be started you would need to open the WebUI on http://127.0.0.1:9000/system/inputs
and configure inputs (adding TCP with either TLS support or without)

### For TCP

```elixir
config :exgraylog,
    autosend_logs: :true,
    transport: 
        %{
            :host     => "127.0.0.1",
            :port     => 12202,
            :protocol => :tcp,
            :opts     => []
        }
```

### For SSL

```elixir
config :exgraylog,
    autosend_logs: :true,
    transport: 
        %{
            :host     => "127.0.0.1",
            :port     => 12202,
            :protocol => :ssl,
            :opts     => [
                {:certfile, "/tmp/certs/app.crt"},
                {:keyfile, "/tmp/certs/app.key"},
                {:cacertfile, "/tmp/certs/ca.crt"},
                {:verify, :verify_peer}
            ]
        }
```

#### SSL Certificates

In order to create (self signed) certificates you should run the following command

```makefile
make generate-certs
```

which will generate ca certificate and key, server and client certificates and will place them to /tmp/certs folder


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `exgraylog` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:exgraylog, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/exgraylog](https://hexdocs.pm/exgraylog).

