defmodule ExGrayLog.SSLTransport do
    @behaviour ExGrayLog.TransportBehavior
    use GenServer
    
    @connect_interval 1 * 10 * 1000

    require Logger

    alias ExGrayLog.SSLTransport

    defstruct [
        :host, :port, :tref, 
        :socket, :connected, :transport_opts
    ]

    def send(message) do
        GenServer.call(__MODULE__, {:message, message})
    end

    def start_link(host, port, opts) do
        GenServer.start_link(__MODULE__, [host, port, opts], name: __MODULE__)
    end


    def init([host, port, opts]) do 
        state = %SSLTransport{
            :host => to_char_list(host), 
            :port => port, 
            :socket => :nil,
            :transport_opts => [:binary, {:active, :true}, {:server_name_indication, :disable}] ++ opts,
            :connected => :false}
        new_state = init_connection_timer(state)
        {:ok, new_state}
    end

    def handle_info(:connect, state) do
        transport_opts = state.transport_opts
        
        state = case :ssl.connect(state.host, state.port, transport_opts) do
            {:ok, socket} -> 
                Logger.info "Connected to graylog"
                %{state | socket: socket, connected: :true}
            {:error, error} ->
                Logger.error "Failed to establish connection because of: #{inspect error}\
                              Current state: #{inspect state}"
                init_connection_timer(state)
        end
        {:noreply, state}
    end

    def handle_info({:ssl_closed, _socket}, state) do 
        Logger.error "Connection to graylog closed"
        {:noreply, init_connection_timer(%{state | socket: :undefined, connected: :false})};
    end

    def handle_info(msg, state) do
        Logger.error "Unexpected message #{inspect msg}"
        {:noreply, state}
    end

    def handle_call({:message, _}, _from, state = %{:connected => :false}) do
        {:reply, {:error, :not_connected}, state}
    end

    def handle_call({:message, message}, _from, state) do
        :ssl.send(state.socket, <<message::binary, 0::8>>)
        {:reply, :ok, state}
    end


    defp init_connection_timer(state = %{:connected => :true}) do
        state
    end
    defp init_connection_timer(state) do
        case state.tref do
            :nil -> :ok
            tref -> Process.cancel_timer(tref)
        end
        tref = Process.send_after(self(), :connect, @connect_interval)
        %{state | tref: tref}
    end
end