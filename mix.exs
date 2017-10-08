defmodule Watcher.Mixfile do
  use Mix.Project

  @description """
    Watcher for GenEvent
  """

  def project do
    [app: :watcher,
     version: "1.1.0",
     elixir: "~> 1.1",
     name: "Watcher",
     description: @description,
     package: package(),
     deps: deps(),
     docs: [main: "Watcher", readme: "README.md",
            source_url: "https://github.com/edgurgel/watcher"],
     test_coverage: [tool: Coverex.Task, coveralls: true],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
     [{ :coverex, "~> 1.4.7", only: :test },

      { :earmark, "~> 1.0", only: :dev },
      { :ex_doc, "~> 0.14", only: :dev }]
  end

  defp package do
    [ maintainers: ["Eduardo Gurgel Pinho"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/edgurgel/watcher"} ]
  end
end
