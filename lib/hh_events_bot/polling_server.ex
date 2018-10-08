defmodule HHEventsBot.Server do

  use GenServer
  import Logger

  def start_link(token) do
    GenServer.start_link(__MODULE__, token, name: __MODULE__)
  end

  def init(token) do
    # new ETS table
    tabref = :ets.new(:processed_data, [:set, :protected])
    {:ok, %{table_ref: tabref, token: token}}
  end

  def handle_call({:get_token}, _, state) do
    {:reply, state.token, state}
  end


  def get_token do
    GenServer.call(__MODULE__, {:get_token})
  end

end
