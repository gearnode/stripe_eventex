defmodule StripeEventex.Application do
  @moduledoc """
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(StripeEventex.Worker, [])
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: StripeEventex.Supervisor
    )
  end
end
