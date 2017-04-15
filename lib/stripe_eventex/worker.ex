defmodule StripeEventex.Worker do
  @moduledoc """
  """

  use GenServer

  @doc"""
  """
  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc"""
  GenServer.init/1 callback
  """
  def init(state), do: {:ok, state}

  @doc"""
  GenServer.handle_call/3 callback
  """
  def handle_call(event_name, _from, state) do
    IO.inspect "Calling : #{event_name}"
    {:reply, state, state}
  end
end
