defmodule HHEventsBot.Server do

  use GenServer
  import Logger

  def start_link([token, msg]) do
    GenServer.start_link(__MODULE__, [token, msg], name: __MODULE__)
  end

  def init([token, msg]) do
    # new ETS table
    tabref = :ets.new(:processed_data, [:set, :public])
    # get latest update_id
    update_id = HHEventsBot.initial(token)
    # run the scheduler
    Task.start_link(HHEventsBot.Server, :schedule, [])
    # initial state
    {:ok, %{table_ref: tabref, token: token, last_update_id: update_id, message: msg}}
  end

  def handle_call({:get_token}, _, state) do
    {:reply, state.token, state}
  end

  def handle_call({:get_message}, _, state) do
    {:reply, state.message, state}
  end

  def handle_cast({:update_last_update_id, update_id}, state) do
    {:noreply, %{ state | last_update_id: update_id }}
  end

  def handle_info(:do_poll, state) do
    Logger.debug("will poll now!")
    Task.start(HHEventsBot, :start_poll, [state])
    {:noreply, state}
  end


  def get_token do
    GenServer.call(__MODULE__, {:get_token})
  end

  def get_message do
    GenServer.call(__MODULE__, {:get_message})
  end

  def update_last_update_id(update_id) do
    GenServer.cast(__MODULE__, {:update_last_update_id, update_id})
  end

  def schedule do
    send(__MODULE__, :do_poll)
    :timer.sleep(3600)
    schedule()
  end


end
