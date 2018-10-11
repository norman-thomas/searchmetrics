defmodule SearchMetrics.Cron do
  use GenServer
  require Logger
  alias SearchMetrics.Interface.CrawlerService

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
    Logger.info("Running cron...")

    spawn(fn ->
      work()
    end)

    {:noreply, state}
  end

  defp schedule(ms \\ @day) do
    Process.send_after(self(), :cron, ms)
  end

  defp work() do
    metrics =
      get_domains()
      |> String.split("\n")
      |> Enum.map(&fetch_and_parse/1)

    metrics
  end

  defp get_domains() do
    File.read!(@domains_file)
    |> Enum.reject(&(String.length(&1) < 4))
  end

  defp fetch_and_parse(domain) do
    domain
    |> CrawlerService.fetch()
    |> CrawlerService.parse(domain)
  end
end
