defmodule SearchMetrics.Interface.CrawlerService do
  @name __MODULE__

  @doc """
  Send a request to the server to crawl searchmetrics for a given domain
  """
  @spec crawl(String.t()) :: String.t() | nil
  def crawl(domain) do
    # 15 sec timeout
    GenServer.call(@name, {:crawl, domain}, 15_000)
  end

  @doc """
  Parse an HTML page crawled from searchmetrics
  """
  @spec parse(String.t(), String.t()) :: SearchMetrics.Metrics.t()
  def parse(domain, html) do
    # 15 sec timeout
    GenServer.call(@name, {:parse, domain, html}, 15_000)
  end
end
