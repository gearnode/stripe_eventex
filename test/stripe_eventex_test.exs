# {:ok, _} = Plug.Adapters.Cowboy.http StripeEventex, [verify_event: true, path: "/"]
defmodule Stripe.CustomerCreated do
  def perform(_opts) do
  end
end

defmodule StripeEventexTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule TrueStripeValidation do
    def valid!(conn) do
      true
    end
  end

  defmodule FalseStripeValidation do
    def valid!(conn) do
      false
    end
  end

  @opts StripeEventex.init([path: "/", validation: &TrueStripeValidation.valid!/1])

  test "when method request is not POST" do
    Enum.each([:get, :head, :patch, :delete, :option], fn method ->
      assert_raise FunctionClauseError, fn ->
        StripeEventex.call(conn(method, "/", ""), @opts)
      end
    end)
  end

  test "when path arguments is not present" do
    assert_raise ArgumentError, fn ->
      StripeEventex.call(conn(:post, "/", Poison.encode!(%{event: "unknown"})), StripeEventex.init([path: "/"]))
    end
  end

  test "when validation arguments is not present" do
    assert_raise ArgumentError, fn ->
      StripeEventex.call(conn(:post, "/", Poison.encode!(%{event: "unknown"})), StripeEventex.init([]))
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
      StripeEventex.call(conn, @opts)
    end
  end

  test "when subcribed event success" do
    conn = StripeEventex.call(conn(:post, "/", Poison.encode!(%{event: "customer.created"})), @opts)
    assert conn.status == 200
    assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
    assert conn.resp_body == Poison.encode!(%{message: "success"})
  end

  test "when validation fail" do
    conn = StripeEventex.call(conn(:post, "/", Poison.encode!(%{event: "customer.created"})), StripeEventex.init([path: "/", validation: &FalseStripeValidation.valid!/1]))
    assert conn.status == 403
    assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
  end
end
