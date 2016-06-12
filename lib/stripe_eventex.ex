# {:ok, _} = Plug.Adapters.Cowboy.http StripeEventex, []
defmodule Stripe.CustomerCreated do
	def perform(_opts) do
		IO.puts "Hello World"
	end
end

defmodule StripeEventex do
	@moduledoc """
  A plug for response to stripe event
  To use it, just plug it into the desired module.
      plug Plug.StripeEventex
  """

	import Plug.Conn

	defmodule MissingStripeEventModule do
		@moduledoc """
    Error raised when apply peform module fail
    """

		defexception message: "Missing module for performing this Stripe event"
	end

  def init(_opts) do
  	Application.get_env(:stripe_eventex, :subscibed_events)
  end

  def call(conn, events) do
  	body = conn |> parse_body

  	# dont't forget verify event

		case retrieve_event(events, body) do
			{_, module} -> subscribed_event(conn, module, body)
			nil -> unknown_event(conn)
			_ -> raise ArgumentError
		end
  end

  defp parse_body(conn) do
  	{:ok, raw_body, _} = read_body(conn, length: 1_000_000)
		Poison.decode!(raw_body)
  end

  defp retrieve_event(events, body) do
  	List.keyfind(events, body["event"], 0)
  end

  defp subscribed_event(conn, module, body) do
		Kernel.apply(module, :perform, [body])
  	send_response(conn, "success")
	rescue
		UndefinedFunctionError ->
			send_response(conn, "fail (MissingStripeEventModule was raised check your logs)")
			raise MissingStripeEventModule, message: "Missing #{module} for performing this Stripe event"
  end

  defp unknown_event(conn) do
  	send_response(conn, "success (not subscribed)")
  end

  defp send_response(conn, message) do
  	conn
  	|> put_resp_content_type("application/json")
  	|> send_resp(200, Poison.encode!(%{message: message}))
  end
end
