defmodule Properex.MixFile do
  use Mix.Project

  def project do
    [app: :properex, version: "0.1.0", deps: deps, elixir: "~> 1.0.0 or ~> 0.15.1"]
  end

  def application, do: []

  defp deps do
    [ # proper has no explicit version config but tags in github
    {:proper, github: "manopapad/proper"}]
  end
end
