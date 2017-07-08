defmodule StripeEventex do
  @moduledoc """
  A plug middleware to handle stripe webhook without any problems.

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

  def init(options) do
    unless options[:path], do: raise ArgumentError, message: "missing require argument 'path'"
    unless options[:validation], do: raise ArgumentError, message: "missing require argument 'validation'"
    options
  end

  def call(%Plug.Conn{request_path: path, method: "POST"} = conn, options) do
    with true <- path == options[:path],
         true <- options[:validation].(conn), do: do_call(conn)
  end


  defp do_call(conn) do
    conn
    |> get_req_body
    |> perform
    |> send_response(201, "success")
  end

  defp perform(body) do
    to_tuple(body["event"])
    |> retrieve_subscribed_treatments()
    |> apply_treatments(body)
  end

  defp get_req_body(conn) do
    {:ok, raw_body, _} = read_body(conn)
    raw_body |> Poison.decode!
  end

  defp subscibed_events, do: Application.get_env(:stripe_eventex, :subscibed_events, [])

  defp to_tuple(string), do: string |> String.split(".") |> List.to_tuple()

  defp retrieve_subscribed_treatments({receive_resource, receive_action}) do
    Enum.filter(subscibed_events(), fn {event, _} ->
      case to_tuple(event) do
        {"*", "*"} -> true
        {"*", ^receive_action} -> true
        {^receive_resource, "*"} -> true
        {^receive_resource, ^receive_action} -> true
        _ -> false
      end
    end)
  end

  defp apply_treatments([], body), do: :ok
  defp apply_treatments([{_, fun} | t], body) do
    %{pid: pid} = Task.async(fn -> fun.(body)  end)
    Process.monitor(pid)
    apply_treatments(t, body)
  end
end
