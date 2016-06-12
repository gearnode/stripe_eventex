defmodule StripeEventex.Mixfile do
  use Mix.Project

  def project do
    [app: :stripe_eventex,
     version: "1.0.0",
     elixir: "~> 1.2",
     description: description,
     package: package,
     deps: deps]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [{:cowboy, "~> 1.0.0"},
     {:plug, "~> 1.0"},
     {:poison, "~> 2.0"}]
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
