defmodule SearchMetrics.Metrics do
  @typedoc """
  Struct that contains the searchmetrics scores
  """

  defstruct desktop: nil,
            mobile: nil,
            seo: nil,
            paid: nil,
            link: nil,
            social: nil

  @type t :: %SearchMetrics.Metrics{
          desktop: integer | nil,
          mobile: integer | nil,
          seo: integer | nil,
          paid: integer | nil,
          link: integer | nil,
          social: integer | nil
        }
end
