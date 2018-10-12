defmodule SearchMetrics.Interface.CrawlerService do
  require Logger

  @name __MODULE__

  # 15 sec timeout
  @timeout 15_000

  @doc """
  Fetches and parses the searchmetrics page for a given domain
  """
  @spec execute(String.t()) :: keyword()
  def execute(domain) do
    domain
    |> fetch()
    |> parse()
    |> Kernel.++(domain: domain)
  end

  @spec fetch(String.t()) :: {:ok, keyword()} | {:error, atom()}
  defp fetch(domain) when is_binary(domain) and byte_size(domain) > 0 do
    GenServer.call(@name, {:fetch, domain}, @timeout)
  end

  @spec parse({:ok, keyword()} | {:error, atom()}) :: keyword()
  defp parse(data) when is_list(data) do
    GenServer.call(@name, {:parse, data}, @timeout)
  end

  defp parse({:error, reason}) do
    Logger.warn("#{__MODULE__}: skipping parsing of failed download (#{to_string(reason)})")
    []
  end
end
