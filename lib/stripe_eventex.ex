defmodule StripeEventex do
  @moduledoc """
  A plug for response to stripe event
  To use it, just plug it into the desired module.
  plug Plug.StripeEventex

  ## Example
      defmodule StripeEvent do
        import Plug.Conn
        use Plug.Router
        plug StripeEventex, path: "/", validation: &StripeEvent.is_authorized/1
        plug :match
        plug :dispatch
        def is_authorized(conn), do: true
      end
  """

  import Plug.Conn

  defmodule MissingStripeEventModule do
    @moduledoc """
    Error raised when apply peform module fail
    """

    defexception message: "Missing module for performing this Stripe event"
  end

  def init(options) do
    unless options[:path], do: raise ArgumentError, message: "missing require argument 'path'"
    unless options[:validation], do: raise ArgumentError, message: "missing require argument 'path'"
    options
  end

  def call(%Plug.Conn{request_path: path, method: method} = conn, options) when method == "POST" do
    if path == options[:path] do
      if options[:validation].(conn) do
        conn |> proccess_event
      else
        conn |> send_response(403, "unauthorized")
      end
    end
  end

  defp proccess_event(conn) do
    body = conn |> parse_body
    case retrieve_event(events(), body) do
      {_, module} -> subscribed_event(conn, module, body)
      nil -> unknown_event(conn)
      _ -> raise ArgumentError
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
