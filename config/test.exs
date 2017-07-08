use Mix.Config
config :stripe_eventex, api_key: "stripe_api_key"
config :stripe_eventex, subscibed_events: [
	{"customer.created", &IO.inspect/1},
	{"customer.updated", &IO.inspect/1} ]
