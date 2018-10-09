defmodule SearchMetrics do
  @moduledoc """
  Documentation for SearchMetrics.
  """

  use Application


  def start(_type, _args) do
    children = [
    ]
 
    opts = [strategy: :one_for_one, name: SearchMetrics.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
