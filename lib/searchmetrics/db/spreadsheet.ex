defmodule SearchMetrics.Spreadsheet do
  use GenServer

  @name SearchMetrics.Interface.Spreadsheet

  @sheet_id "1AZ2w5p0j4usCThuBSpckKnpGRaoCfH6wlthMVUPrzNI"
  @columns [:date, :domain, :desktop, :mobile, :seo, :paid, :link, :social]

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  @impl true
  def init(:ok) do
    {:ok, pid} = GSS.Spreadsheet.Supervisor.spreadsheet(@sheet_id)
    state = %{pid: pid}
    {:ok, state}
  end

  defp append(pid, %SearchMetrics.Metrics{} = row) do
    values =
      @columns
      |> Enum.map(&Map.fetch!(row, &1))

    :ok = GSS.Spreadsheet.append_row(pid, 1, values)
  end

  @impl true
  def handle_cast({:append, %SearchMetrics.Metrics{} = row}, state) do
    append(state.pid, row)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:append, [%SearchMetrics.Metrics{} | _] = rows}, state) do
    rows
    |> Enum.map(&append(state.pid, &1))

    {:noreply, state}
  end
end
