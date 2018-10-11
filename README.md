# Searchmetrics

Searchmetrics.com crawler in Elixir

Integrated cron crawls once per day and write results into a Google Spreadsheet.


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


## Usage

```elixir
iex> SearchMetrics.Interface.CrawlerService.execute("google.com")
%SearchMetrics.Metrics{
  date: ~D[2018-10-15],
  domain: "google.com",
  desktop: 13953,
  link: 2006,
  mobile: 16785,
  paid: 0,
  seo: 1910,
  social: 0
}
```
