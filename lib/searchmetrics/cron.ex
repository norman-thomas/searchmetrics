defmodule SearchMetrics.Cron do
  @moduledoc """
  Cron which takes care of scheduling the download, parsing and storing of searchmetrics data
  """

  use GenServer
  require Logger

  import SearchMetrics.Utils
  alias SearchMetrics.Interface.CrawlerService
  alias SearchMetrics.Interface.Spreadsheet

  @name __MODULE__

  # time in milliseconds
  @minute 60 * 1000
  @day 24 * 60 * @minute
  # @week 7 * @day

  @domains_file "./compare.txt"

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    Logger.info("Starting #{__MODULE__} process...")
    schedule(@minute)
    {:ok, %{ms: @day}}
  end

  def handle_cast({:timeout, ms}, state) do
    new_state = %{state | ms: ms}
    {:noreply, new_state}
  end

  def handle_info(:cron, state) do
    schedule(state.ms)
    Logger.info("Re-scheduled cron.")

    spawn(fn ->
      work()
    end)

    {:noreply, state}
  end

  defp schedule(ms) do
    Process.send_after(self(), :cron, ms)
  end

  def work() do
    Logger.debug("Executing cron...")

    data =
      get_domains()
      |> Enum.map(&CrawlerService.execute/1)
      |> Enum.reject(&Enum.empty?/1)

    data
    |> Enum.map(&overview_row/1)
    |> Spreadsheet.append_rows(:visibility)

    data
    |> Enum.map(&social_rows/1)
    |> Spreadsheet.append_rows(:social)

    Logger.debug("Cron done.")
  end

  @spec get_domains() :: list(String.t())
  defp get_domains() do
    @domains_file
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(&(String.length(&1) < 4))
  end

  def overview_row(data) do
    g = &deep_get/2

    [
      date: g.(data, [:date]),
      domain: g.(data, [:domain]),
      desktop: g.(data, [:visibility, :desktop]),
      mobile: g.(data, [:visibility, :mobile]),
      seo: g.(data, [:rank, :seo]),
      paid: g.(data, [:rank, :paid]),
      link: g.(data, [:rank, :link]),
      social: g.(data, [:rank, :social])
    ]
  end

  def social_rows(data) do
    to_add = [date: deep_get(data, [:date]), domain: deep_get(data, [:domain])]

    data
    |> deep_get([:social])
    |> Enum.map(fn row -> to_add ++ row end)
  end
end
