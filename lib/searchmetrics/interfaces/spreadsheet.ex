defmodule SearchMetrics.Interface.Spreadsheet do
  @moduledoc """
  Interface of helper to append rows to a Google spreadsheet
  """

  @name __MODULE__

  @spec append_rows(list(keyword()), atom()) :: :ok
  def append_rows([[_ | _] | _] = rows, type) do
    :ok = GenServer.cast(@name, {:append, type, rows})
  end

  @spec append_row(keyword(), atom()) :: :ok
  def append_row([_ | _] = row, type) do
    :ok = GenServer.cast(@name, {:append, type, [row]})
  end
end
