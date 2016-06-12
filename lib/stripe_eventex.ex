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

  def init(options) do
    if List.keyfind(options, :path, 0), do: options, else: raise ArgumentError, message: "path is a require argument"
  end

  def call(conn, options) do
    {_, path} = List.keyfind(options, :path, 0)
    if conn.request_path == path do
      body = conn |> parse_body

      # dont't forget verify event
      case retrieve_event(events, body) do
        {_, module} -> subscribed_event(conn, module, body)
        nil -> unknown_event(conn)
        _ -> raise ArgumentError
      end
    end
  end

  defp events do
    Application.get_env(:stripe_eventex, :subscibed_events) || []
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
  	send_response(conn, 200, "success")
	rescue
		UndefinedFunctionError ->
			send_response(conn, 500, "fail (MissingStripeEventModule was raised check your logs)")
			raise MissingStripeEventModule, message: "Missing #{module} for performing this Stripe event"
    # plus de gestion d'erreur
  end

  defp unknown_event(conn) do
  	send_response(conn, 200, "success (not subscribed)")
  end

  defp send_response(conn, code, message) do
  	conn
  	|> put_resp_content_type("application/json")
  	|> send_resp(code, Poison.encode!(%{message: message}))
  end
end
