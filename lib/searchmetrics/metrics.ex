defmodule SearchMetrics.Metrics do
  @typedoc """
  Struct that contains the searchmetrics scores
  """

  defstruct domain: "",
            desktop: 0,
            mobile: 0,
            seo: 0,
            paid: 0,
            link: 0,
            social: 0

  @type t :: %SearchMetrics.Metrics{
          domain: String.t(),
          desktop: integer,
          mobile: integer,
          seo: integer,
          paid: integer,
          link: integer,
          social: integer
        }
end
