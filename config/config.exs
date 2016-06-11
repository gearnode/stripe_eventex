use Mix.Config

config :stripe_eventex, api_key: "stripe_api_key"
config :stripe_eventex, subscibed_events: [
	{"customer.created", Stripe.CustomerCreated},
	{"customer.updated", Stripe.CustomerUpdated} ]
