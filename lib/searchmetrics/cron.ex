defmodule SearchMetrics.Cron do
  use GenServer
  require Logger
  alias SearchMetrics.Interface.CrawlerService
  alias SearchMetrics.Interface.Spreadsheet

  @name __MODULE__

  # time in milliseconds
  @minute 60 * 1000
  @day 24 * 60 * @minute
  @week 7 * @day

  @domains_file "./compare.txt"

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    schedule(@minute)
    {:ok, []}
  end

  def handle_info(:cron, state) do
    schedule(@day)
    Logger.info("Re-scheduled cron.")

    spawn(fn ->
      work()
    end)

    {:noreply, state}
  end

  defp schedule(ms) do
    Process.send_after(self(), :cron, ms)
  end

  defp work() do
    Logger.debug("Running cron...")

    get_domains()
    |> Enum.map(&CrawlerService.execute/1)
    |> Enum.reject(&is_nil/1)
    |> Spreadsheet.append_rows()

    Logger.debug("Cron done.")
  end

  @spec get_domains() :: list(String.t())
  defp get_domains() do
    File.read!(@domains_file)
    |> String.split("\n")
    |> Enum.reject(&(String.length(&1) < 4))
  end
end
