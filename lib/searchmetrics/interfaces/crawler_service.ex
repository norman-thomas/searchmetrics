defmodule SearchMetrics.Interface.CrawlerService do
  require Logger

  @name __MODULE__

  @doc """
  Fetches and parses the searchmetrics page for a given domain
  """
  @spec execute(String.t()) :: SearchMetrics.Metrics.t() | nil
  def execute(domain) do
    domain
    |> fetch()
    |> parse(domain)
  end

  @spec fetch(String.t()) :: {:ok, String.t()} | {:error, atom()}
  defp fetch(domain) when is_binary(domain) and byte_size(domain) > 0 do
    # 15 sec timeout
    GenServer.call(@name, {:fetch, domain}, 15_000)
  end

  @spec parse({:ok, String.t()} | {:error, atom()}, String.t()) :: SearchMetrics.Metrics.t() | nil
  defp parse({:ok, html}, domain) when is_binary(html) do
    # 15 sec timeout
    GenServer.call(@name, {:parse, domain, html}, 15_000)
  end

  defp parse({:error, reason}, domain) do
    Logger.warn("#{domain}: skipping parsing of failed download (#{to_string reason})")
    nil
  end
end
