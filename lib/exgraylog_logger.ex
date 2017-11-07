defmodule ExGrayLog.Logger do
    use GenServer

    require Logger
    def log(msg) do
        GenServer.cast(__MODULE__, {:msg, msg})
    end

    def start_link() do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    def init([]) do
        Logger.add_backend(ExGrayLog.Handler, [])
        {:ok, :nostate}
    end


    def handle_cast({:msg, msg}, state) do
        ExGrayLog.Transport.send(msg)
        {:noreply, state}
    end
end