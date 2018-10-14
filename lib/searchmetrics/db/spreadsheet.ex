defmodule SearchMetrics.Spreadsheet do
  @moduledoc """
  Implementation of helper to append rows to a Google spreadsheet
  """

  use GenServer
  require Logger

  @name SearchMetrics.Interface.Spreadsheet

  @spreadsheet_id %{
    visibility: "1AZ2w5p0j4usCThuBSpckKnpGRaoCfH6wlthMVUPrzNI",
    social: "15KJiUzqcVTYm-l_-7oN-ZmorN4TeQC7nDu88fygNaXw"
  }
  @columns %{
    visibility: [:domain, :date, :desktop, :mobile, :seo, :paid, :link, :social],
    social: [:domain, :date, :platform_code, :amount, :percent]
  }

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  @impl true
  def init(:ok) do
    Logger.info("Starting #{__MODULE__} process...")

    {:ok, visibility_pid} = GSS.Spreadsheet.Supervisor.spreadsheet(@spreadsheet_id.visibility)
    {:ok, social_pid} = GSS.Spreadsheet.Supervisor.spreadsheet(@spreadsheet_id.social)

    state = %{pid: %{visibility: visibility_pid, social: social_pid}}
    {:ok, state}
  end

  @impl true
  def handle_cast({:append, type, [[_ | _] | _] = rows}, state) do
    rows
    |> Enum.each(&append(state, type, &1))

    {:noreply, state}
  end

  defp append(%{pid: pid}, :visibility, [_ | _] = row) do
    pid = pid.visibility

    values =
      @columns.visibility
      |> Enum.map(&Keyword.fetch!(row, &1))

    :ok = GSS.Spreadsheet.append_row(pid, 1, values)
  end

  defp append(%{pid: pid}, :social, [_ | _] = rows) do
    pid = pid.social

    values =
      rows
      |> Enum.map(fn row ->
        @columns.social
        |> Enum.map(&Keyword.fetch!(row, &1))
      end)

    values
    |> Enum.each(fn row ->
      :ok = GSS.Spreadsheet.append_row(pid, 1, row)
    end)
  end
end
