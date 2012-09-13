defmodule Properex.MixFile do
  use Mix.Project

  def project do
    [app: :properex, version: "0.1", deps: deps]
  end

  def application, do: []

  defp deps do
    [{:proper, %r(.*), git: "https://github.com/manopapad/proper"}]
  end
end
