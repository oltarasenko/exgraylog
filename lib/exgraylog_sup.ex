defmodule ExGrayLog.Sup do
    # Automatically defines child_spec/1
    use Supervisor

    def start_link() do
        Supervisor.start_link(__MODULE__, [], name: __MODULE__)
    end

    def init([]) do
        
        children = [
            worker(ExGrayLog.Transport, [], [restart: :permanent]),
            worker(ExGrayLog.Logger, [], [restart: :permanent])
        ]
        
        supervise(children, strategy: :one_for_one)
    end
end
