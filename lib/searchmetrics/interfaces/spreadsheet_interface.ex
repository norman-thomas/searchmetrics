defmodule SearchMetrics.Interface.Spreadsheet do
  @name __MODULE__

  @spec append_row(SearchMetrics.Metrics.t()) :: :ok
  def append_row(%SearchMetrics.Metrics{} = row) do
    :ok = GenServer.cast(@name, {:append, row})
  end

  @spec append_rows(list(SearchMetrics.Metrics.t())) :: :ok
  def append_rows([%SearchMetrics.Metrics{} | _] = rows) do
    :ok = GenServer.cast(@name, {:append, rows})
  end
end
