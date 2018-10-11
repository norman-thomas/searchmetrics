defmodule SearchMetrics.Interface.CrawlerService do
  @name __MODULE__

  @doc """
  Fetches and parses the searchmetrics page for a given domain
  """
  @spec execute(String.t()) :: SearchMetrics.Metrics.t()
  def execute(domain) do
    domain
    |> fetch()
    |> parse(domain)
  end

  @doc """
  Send a request to the server to fetch the searchmetrics page for a given domain
  """
  @spec fetch(String.t()) :: String.t() | nil
  def fetch(domain) do
    # 15 sec timeout
    GenServer.call(@name, {:fetch, domain}, 15_000)
  end

  @doc """
  Parse an HTML page crawled from searchmetrics
  """
  @spec parse(String.t(), String.t()) :: SearchMetrics.Metrics.t()
  def parse(html, domain) do
    # 15 sec timeout
    GenServer.call(@name, {:parse, domain, html}, 15_000)
  end
end
