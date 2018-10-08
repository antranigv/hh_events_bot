defmodule HHEventsBot do
  @moduledoc """
  Documentation for HHEventsBot.
  """

  import Logger

  @doc """
  Hello world.

  ## Examples

      iex> HHEventsBot.hello()
      :world

  """
  def hello do
    :world
  end

  def initial(token) do
    case get_updates(token) do
      {:ok, resp} -> continue_init(resp)
      {:error, msg} -> Logger.warn("something is wrong! => #{inspect msg}")
    end
  end

  def continue_init(resp) do
    resp
    |> decode_resp()
    |> get_last_update_id()
  end

  def start_poll(state) do
    Logger.debug("starting poll :)")
    case get_updates(state.token, state.last_update_id + 1) do
      {:ok, resp} -> continue_poll(resp)
      {:error, msg} -> Logger.warn("something is wrong! => #{inspect msg}")
    end
  end

  def continue_poll(resp) do
    res = resp
    |> decode_resp

    case res do
      [] -> do_exit()
      msgs -> handle_messages(msgs)
    end
  end

  def handle_messages(msgs) do
    msgs
    |> (fn results -> spawn(fn -> get_update_last_update_id(results) end); results end).()
    |> Enum.each(fn msg -> spawn(fn -> reply_msg(msg) end) end)
  end

  def reply_msg(msg) do
    case (msg |> Map.get("message") |> Map.get("text") |> String.contains?("events")) do
      true -> do_reply(msg)
      false -> do_exit()
    end
  end

  def do_reply(msg) do
    msg
    |> Map.get("message")
    |> Map.get("chat")
    |> Map.get("id")
    |> send_msg(HHEventsBot.Server.get_message())
  end

  def do_exit() do
    Process.exit(self(), :kill)
  end

  def get_update_last_update_id(results) do
    results
    |> get_last_update_id
    |> HHEventsBot.Server.update_last_update_id()
  end

  def decode_resp(resp) do
    case resp.status_code do
      200 -> resp.body |> Poison.decode! |> Map.get("result")
      err -> Logger.warn("got status code #{err}")
    end
  end

  def get_last_update_id(results) do
    results
    |> Enum.map(fn m -> m |> Map.get("update_id") end)
    |> Enum.sort()
    |> List.last()
  end

  def get_updates(token, update_id) do
    HTTPoison.get("https://api.telegram.org/bot" <> token <> "/getUpdates?offset=#{update_id |> Integer.to_string}&timeout=2")
  end

  def get_updates(token) do
    HTTPoison.get("https://api.telegram.org/bot" <> token <> "/getUpdates?timeout=2")
  end

  def send_msg(chat_id, msg) do
    postdata = "chat_id=#{chat_id}&text=#{msg}"
    opts = [{"Content-Type", "application/x-www-form-urlencoded"}, {"Content-Length", byte_size(postdata)}]
    HTTPoison.post(
      "https://api.telegram.org/bot" <> HHEventsBot.Server.get_token <> "/sendMessage",
      postdata,
      opts
    )
  end

end
