# Searchmetrics

Searchmetrics.com crawler in Elixir

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `searchmetrics` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:searchmetrics, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/searchmetrics](https://hexdocs.pm/searchmetrics).

## Usage

```elixir
iex> SearchMetrics.search("google.com")
%SearchMetrics.Page{
  domain: "grin.com",
  html: "<!DOCTYPE html>" <> ...,
  metrics: %SearchMetrics.Metrics{
    desktop: 13953,
    link: 2006,
    mobile: 16785,
    paid: 0,
    seo: 1910,
    social: 0
  }
}
```
