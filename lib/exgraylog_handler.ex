defmodule ExGrayLog.Handler do
    require Poison

    def init(_) do
        {:ok, %{}}
    end

    def handle_event({_level, gl, {Logger, _, _, _}}, state) when node(gl) != node() do
        {:ok, state}
    end

    def handle_event({level, _gl, {Logger, message, _ts, metadata}}, state) do
        
        mapped_level = case level do
            :info  -> 6
            :warn  -> 4
            :error -> 3
            _      -> 7
        end

        formatted_message = format_message(metadata, message)
        short_message = case String.length(formatted_message) do
            res when res > 20 ->
                short_message = String.slice(formatted_message, 0..20)
                "#{short_message} ... \""
            _ -> formatted_message
        end
        {:ok, msg} = Poison.encode(%{
            :version => <<"1.0">>, 
            :host => Node.self(),
            :message => "#{short_message}",
            :full_message => formatted_message,
            :level => mapped_level, 
            :timestamp => timestamp(),
        })

        ExGrayLog.Logger.log(msg)
        {:ok, state}
    end

    def format_message(metadata = [_, {:error_logger, _}], message) do
        "#{message}"
    end
    def format_message(_, message) do
       "#{inspect message}"
    end

    def timestamp() do
        {a, b, c} = :os.timestamp()
        time = (a * 1000000000000 + b * 1000000 + c) / 1000000
        :erlang.list_to_binary(:io_lib.format("~f", [time]))
    end

    def handle_info(_msg, state) do
        {:ok, state}
    end
    
end