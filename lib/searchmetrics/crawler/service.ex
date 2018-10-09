defmodule SearchMetrics.CrawlerService do
  @moduledoc """
    Crawler service which has the ability to fetch the searchmetrics page
    for a given domain
  """

  use GenServer
  require Logger

  @name __MODULE__

  ### Client Interface ###

  @doc """
  Start searchmetrics crawler server
  """
  @spec start_link(any()) :: GenEvent.on_start()
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

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

  ### Callbacks ###

  @impl true
  def init(:ok) do
    Logger.debug("starting SearchMetrics.Crawler process...")
    {:ok, []}
  end

  @impl true
  def handle_call({:crawl, domain}, from, state) do
    parent = self()

    spawn(fn ->
      result = SearchMetrics.Crawler.fetch(domain)
      GenServer.call(parent, {:respond, from, result})
    end)

    {:noreply, state}
  end

  @impl true
  def handle_call({:parse, domain, html}, from, state) do
    parent = self()

    spawn(fn ->
      result = SearchMetrics.Parser.get_metrics(domain, html)
      GenServer.call(parent, {:respond, from, result})
    end)

    {:noreply, state}
  end

  @impl true
  def handle_call({:respond, to, response}, _from, state) do
    GenServer.reply(to, response)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(_, _from, state) do
    {:reply, {:error, :unknown_request}, state}
  end
end
