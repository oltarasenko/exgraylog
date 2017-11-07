defmodule ExGrayLog.TransportBehavior do

    # @callback init(state :: term) :: {:ok, new_state :: term} | {:error, reason :: term}
    # @callback connect() :: :ok | {:error, reason :: term}
    @callback send(message :: term) :: :ok | {:error, reason :: term}
    
end