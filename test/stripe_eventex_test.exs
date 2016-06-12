defmodule HelloTest do
defmodule StripeEventexTest do
	use ExUnit.Case, async: true
	use Plug.Test

	@opts StripeEventex.init([])

	test "when unknown event 200 must be returned" do
		conn = StripeEventex.call(conn(:post, "/", Poison.encode!(%{event: "unknown"})), @opts)
		assert conn.status == 200
		assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
		assert conn.resp_body == Poison.encode!(%{message: "success (not subscribed)"})
	end

	test "when is subscribed event fail" do
		conn = conn(:post, "/", Poison.encode!(%{event: "customer.updated"}))
		assert_raise StripeEventex.MissingStripeEventModule, fn ->
			conn = StripeEventex.call(conn, @opts)
		end
	end

	test "" do

	end



	test "the truth" do
		assert 1 + 1 == 2
	end
end
