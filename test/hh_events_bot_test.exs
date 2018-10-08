defmodule HHEventsBotTest do
  use ExUnit.Case
  doctest HHEventsBot

  test "greets the world" do
    assert HHEventsBot.hello() == :world
  end
end
