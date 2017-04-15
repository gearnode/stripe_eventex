defmodule StripeEventex.Mixfile do
  use Mix.Project

  def project do
    [app: :stripe_eventex,
     version: "2.0.0",
     elixir: "~> 1.4",
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    [mod: {StripeEventex.Application, []},
     extra_applications: [:logger]]
  end

  defp deps do
    [{:cowboy, "~> 1.1", only: [:test], optional: true},
     {:plug, "~> 1.3", only: [:test], optional: true},
     {:poison, "~> 3.0"}]
  end

  defp description do
    """
    Stripe webhook integration for Plug.
    """
  end

  defp package do
    [
     name: :stripe_eventex,
     files: ["lib", "test", "config", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Bryan Frimin"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/gearnode/stripe_eventex"}]
  end
end
