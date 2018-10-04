defmodule SearchMetrics.Metrics do
  @moduledoc """
  Struct that contains the searchmetrics score
  """
  defstruct desktop: nil,
            mobile: nil,
            seo: nil,
            paid: nil,
            link: nil,
            social: nil

  @doc """
  Creates a new `SearchMetrics.Metrics` struct with default values
  """
  def new do
    %SearchMetrics.Metrics{}
  end
end
