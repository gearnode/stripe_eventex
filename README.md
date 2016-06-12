# StripeEventex
[![Build Status](https://travis-ci.com/Birdly/birdly-api-2.svg?token=JhpP82VZrtp2xXfLPy5P&branch=master)](https://travis-ci.com/Birdly/birdly-api-2)


**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

Add hello to your list of dependencies in `mix.exs`:

    def deps do
      [{:stripe_eventex, "~> 1.0.0}]
    end
    
Then run mix do deps.get, deps.compile inside your project's directory.

## Usage

    defmodule StripeEventApplication do
      import Plug.Conn
      use Plug.Router

      plug StripeEventex, path: "/", validation: &StripeEventApplication.valid!/1
      plug :match
      plug :dispatch

      get "/super_app" do
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(200, "Hello, World")
      end

      def valid!(conn), do: true
    end

### The validation callback

The validation callback will be called to decide if the stripe event is authorized or not.

- It has to be defined in the format &Mod.fun/1.
- It receives %Plug.Conn.__struct__, and must return true or false
