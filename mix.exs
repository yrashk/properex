defmodule Properex.MixFile do
  use Mix.Project

  def project do
    [app: :properex, version: "0.1", deps: deps, elixir: ">= 0.10.0"]
  end

  def application, do: []

  defp deps do
    [ # proper has no explicit version config but tags in github
    {:proper, ">= 1.1", github: "manopapad/proper"}]
  end
end
