defmodule SearchMetrics.CrawlerService do
  @moduledoc """
    Crawler service which has the ability to fetch the searchmetrics page
    for a given domain
  """

  use GenServer
  require Logger

  @name SearchMetrics.Interface.CrawlerService

  ### Client Interface ###

  @doc """
  Start searchmetrics crawler server
  """
  @spec start_link(any()) :: GenEvent.on_start()
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  ### Callbacks ###

  @impl true
  def init(:ok) do
    Logger.info("Starting #{__MODULE__} process...")
    {:ok, []}
  end

  @impl true
  def handle_call({:fetch, domain}, from, state) do
    parent = self()

    spawn(fn ->
      result = SearchMetrics.Crawler.fetch(domain)
      GenServer.call(parent, {:respond, from, result})
    end)

    {:noreply, state}
  end

  @impl true
  def handle_call({:parse, data}, from, state) do
    parent = self()

    spawn(fn ->
      result = SearchMetrics.Parser.parse(data)
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
