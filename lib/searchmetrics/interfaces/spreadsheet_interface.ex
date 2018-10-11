defmodule SearchMetrics.Interface.Spreadsheet do
  @name __MODULE__

  def append_row(%SearchMetrics.Metrics{} = row) do
    GenServer.cast(@name, {:append, row})
  end
end
