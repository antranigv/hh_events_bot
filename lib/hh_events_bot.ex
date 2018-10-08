defmodule HHEventsBot do
  @moduledoc """
  Documentation for HHEventsBot.
  """

  @doc """
  Hello world.

  ## Examples

      iex> HHEventsBot.hello()
      :world

  """
  def hello do
    :world
  end

  def get_updates do
    HTTPoison.get("https://api.telegram.org/bot" <> HHEventsBot.Server.get_token <> "/getUpdates")
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
