defmodule ExGrayLog do

    def send(message) do
        ExGrayLog.Transport.send(message)
    end
    
end