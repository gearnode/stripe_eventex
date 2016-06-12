# {:ok, _} = Plug.Adapters.Cowboy.http StripeEventex, [log: true, verify_event: true, path: "/"]
defmodule Stripe.CustomerCreated do
  def perform(_opts) do
  end
end

# plug StripeEventex, log: true, verify_event: true, path: "/"

defmodule StripeEventexTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts StripeEventex.init([path: "/", verify_event: false])

  test "when method request is not POST" do
    Enum.each([:get, :head, :patch, :delete, :option], fn method ->
      assert_raise FunctionClauseError, fn ->
        StripeEventex.call(conn(method, "/", ""), @opts)
      end
    end)
  end

  test "when path arguments is not present" do
    assert_raise ArgumentError, fn ->
      conn = StripeEventex.call(conn(:post, "/", Poison.encode!(%{event: "unknown"})), StripeEventex.init([]))
    end
  end

  test "when unknown event, 200 must be returned" do
    conn = StripeEventex.call(conn(:post, "/", Poison.encode!(%{event: "unknown"})), @opts)
    assert conn.status == 200
    assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
    assert conn.resp_body == Poison.encode!(%{message: "success (not subscribed)"})
  end

  test "when payload is empty, 200 must be returned" do
    conn = StripeEventex.call(conn(:post, "/", Poison.encode!(%{})), @opts)
    assert conn.status == 200
    assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
    assert conn.resp_body == Poison.encode!(%{message: "success (not subscribed)"})
  end

  test "when subscribed event fail" do
    conn = conn(:post, "/", Poison.encode!(%{event: "customer.updated"}))
    assert_raise StripeEventex.MissingStripeEventModule, fn ->
      conn = StripeEventex.call(conn, @opts)
    end
  end

  test "when subcribed event " do
    conn = StripeEventex.call(conn(:post, "/", Poison.encode!(%{event: "customer.created"})), @opts)
    assert conn.status == 200
    assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
    assert conn.resp_body == Poison.encode!(%{message: "success"})
  end
end
