defmodule SearchMetrics.Database do
  use GenServer
  require Logger

  @name __MODULE__
  @tablename SearchMetrics
  @columns [:date, :domain, :desktop, :mobile, :seo, :paid, :link, :social]

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  @impl true
  def init(:ok) do
    Logger.debug("starting #{__MODULE__} process...")
    :ok = init_mnesia()
    {:ok, []}
  end

  def init_mnesia() do
    :mnesia.start()

    result = :mnesia.create_table(@tablename, attributes: @columns)

    :mnesia.add_table_index(@tablename, :domain)

    case result do
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, @tablename}} -> :ok
      _ -> :error
    end
  end

  defp insert(%SearchMetrics.Metrics{} = metrics) do
    today_str = Date.to_iso8601(Date.utc_today())

    :ok =
      :mnesia.dirty_write(
        {@tablename, today_str, metrics.domain, metrics.desktop, metrics.mobile, metrics.seo,
         metrics.paid, metrics.link, metrics.social}
      )
  end

  def handle_call({:insert, %SearchMetrics.Metrics{} = metrics}, _from, state) do
    :ok = insert(metrics)
    {:reply, :ok, state}
  end

  def handle_call({:read, domain}, _from, state) do
    result = :not_yet_implemented
    {:replace, result, state}
  end
end
