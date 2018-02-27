defmodule ExProgress.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_progress,
      version: "0.1.0",
      elixir: "~> 1.6",
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
      ]
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
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
