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
        app_enabled = Application.get_env(:exgraylog, :enabled, :false)
        autosend_logs = Application.get_env(:exgraylog, :autosend_logs, :false)
        case {app_enabled, autosend_logs} do
            {:true, :true} ->
                Logger.add_backend(ExGrayLog.Handler, [])
                {:ok, :nostate}
            _  -> :ignore
        end
    end


    def handle_cast({:msg, msg}, state) do
        ExGrayLog.Transport.send(msg)
        {:noreply, state}
    end
end