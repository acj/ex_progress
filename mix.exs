defmodule ExProgress.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_progress,
      version: "1.0.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: "A library for tracking progress across many cooperating tasks",
      package: [
        maintainers: ["Adam Jensen"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/acj/ex_progress"},
      ],

      # Docs
      docs: [
        extras: [
          "README.md": [title: "README", name: "readme"],
        ],
        main: "readme",
      ],

      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end
end
