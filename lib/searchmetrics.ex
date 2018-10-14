defmodule SearchMetrics do
  @moduledoc """
  SearchMetrics Application
  """

  use Application

  def start(_type, _args) do
    SearchMetrics.Supervisor.start_link()
  end
end
