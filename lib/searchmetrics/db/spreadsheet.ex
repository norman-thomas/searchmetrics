defmodule SearchMetrics.Spreadsheet do
  use GenServer
  require Logger

  @name SearchMetrics.Interface.Spreadsheet

  @spreadsheet_id "1AZ2w5p0j4usCThuBSpckKnpGRaoCfH6wlthMVUPrzNI"
  @columns %{
    visibility: [:domain, :date, :desktop, :mobile, :seo, :paid, :link, :social],
    social: [:domain, :date, :platform, :platform_code, :amount, :percent]
  }

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  @impl true
  def init(:ok) do
    Logger.info("Starting #{__MODULE__} process...")
    {:ok, pid} = GSS.Spreadsheet.Supervisor.spreadsheet(@spreadsheet_id)
    state = %{pid: pid}
    {:ok, state}
  end

  @impl true
  def handle_cast({:append, type, [[_ | _] | _] = rows}, state) do
    rows
    |> Enum.map(&append(state.pid, type, &1))

    {:noreply, state}
  end

  defp append(pid, :visibility, [_ | _] = row) do
    sheet_id = get_sheet_id(pid, :visibility)

    values =
      @columns.visibility
      |> Enum.map(&Keyword.fetch!(row, &1))

    :ok = GSS.Spreadsheet.append_row(pid, 1, values, sheet_id: sheet_id)
  end

  defp append(pid, :social, [_ | _] = rows) do
    sheet_id = get_sheet_id(pid, :social)

    values =
      rows
      |> Enum.map(fn row ->
        @columns.social
        |> Enum.map(&Keyword.fetch!(row, &1))
      end)

    values
    |> Enum.each(:ok = &GSS.Spreadsheet.append_row(pid, 1, &1, sheet_id: sheet_id))
  end

  defp get_sheet_id(pid, :visibility) do
    GSS.Spreadsheet.sheets(pid)
    |> Map.fetch!("Visibility Log")
    |> Map.fetch!("sheetId")
  end

  defp get_sheet_id(pid, :social) do
    GSS.Spreadsheet.sheets(pid)
    |> Map.fetch!("Social Log")
    |> Map.fetch!("sheetId")
  end
end
