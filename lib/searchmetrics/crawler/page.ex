defmodule SearchMetrics.Page do
  defstruct html: nil,
            metrics: %SearchMetrics.Metrics{}

  @type t :: %SearchMetrics.Page{
          html: String.t() | nil,
          metrics: SearchMetrics.Metrics.t()
        }
end
