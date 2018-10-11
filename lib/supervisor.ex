defmodule SearchMetrics.Supervisor do
  use Supervisor

  @name __MODULE__

  def start_link(_args \\ []) do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      SearchMetrics.CrawlerService,
      SearchMetrics.Spreadsheet,
      SearchMetrics.Cron
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
