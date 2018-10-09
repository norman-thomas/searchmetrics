defmodule SearchMetrics do
  @moduledoc """
  Documentation for SearchMetrics.
  """

  use Application


  def start(_type, _args) do
    SearchMetrics.Supervisor.start_link()
  end
end
