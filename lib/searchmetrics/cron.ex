defmodule SearchMetrics.Cron do
  use GenServer
  require Logger

  @name __MODULE__

  # time in milliseconds
  @week 7 * 24 * 60 * 60 * 1000
  @minute 60 * 1000

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    schedule(@minute)
    {:ok, []}
  end

  def handle_info(:cron, state) do
    schedule()
    work()
    Logger.info("Running cron...")
    {:noreply, state}
  end

  defp schedule(ms \\ @week) do
    Process.send_after(self(), :cron, ms)
  end

  defp work() do
    # TODO crawl URLs from compare.txt
    nil
  end
end
