defmodule ExGrayLog.Transport do
    use GenServer

    require Logger
    
    alias ExGrayLog.Transport

    defstruct [
        :transport_backend, :host, :port
    ]

    def send(message) do
        GenServer.call(__MODULE__, {:message, message})
    end

    def start_link() do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end


    def init([]) do 
        transport = Application.fetch_env!(:exgraylog, :transport)

        transport_backend = case transport.protocol do
            :tcp -> ExGrayLog.TcpTransport
            :ssl -> ExGrayLog.SSLTransport
            other ->
                Logger.error "#{other} transport module is not supported yet"
                Process.exit(self(), :transport_protocol_not_supported)
        end
        {:ok, pid} = transport_backend.start_link(transport.host, transport.port, transport.opts) 
        Process.monitor(pid)

        state = %Transport{:transport_backend => transport_backend}
        {:ok, state}
    end

    def handle_call({:message, message}, _from, state) do
        state.transport_backend.send(message)
        {:reply, :ok, state}
    end

    def handle_info({:DOWN, _ref, :process, _pid, reason}, state) do
        # Transport module have crashed, we're crashing this process as well
        # and allowing supervisor to restart it.
        Logger.info "Stopping #{reason}"
         {:stop, :normal, state}
    end

end