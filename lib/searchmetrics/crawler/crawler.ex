defmodule SearchMetrics.Crawler do
  @moduledoc """
    Crawler service which has the ability to fetch the searchmetrics page
    for a given domain
  """

  require Logger

  @host "https://suite.searchmetrics.com"

  @metrics [:visibility, :geo, :rank, :social, :seo_paid]

  def fetch(domain, country \\ "DE") do
    for metric <- @metrics, do: {metric, url(domain, country, metric) |> request}
  end

  defp request({url, params}) do
    {:ok, response} = HTTPoison.post!(url, params)
    response
  end

  defp url(domain, country, :visibility) do
    url = "#{@host}/kpi_research_seosem_trend/organic-visibility-spread"

    params = %{
      url: domain,
      cc: country,
      filter: %{},
      type: "",
      link: "",
      acc: ""
    }

    {url, params}
  end

  defp url(domain, country, :geo) do
    url = "#{@host}/custom-module_research_seosem/geo-visibility"

    params = %{
      url: domain,
      cc: country,
      filter: %{},
      type: "",
      link: "",
      acc: 0
    }

    {url, params}
  end

  defp url(domain, country, :rank) do
    url = "#{@host}/kpi_research_seosem_value/rank-spread"

    params = %{
      url: domain,
      cc: country,
      filter: %{},
      type: "",
      link: "",
      acc: 0
    }

    {url, params}
  end

  defp url(domain, country, :social) do
    url = "#{@host}/chart_research_seosem_line/seo-paid-visibility"

    params = [
      { "url", domain },
      { "cc", country },
      { "filter", %{} },
      { "module", "chart_research_seosem_line" },
      { "action", "grid/socialspread" },
      { "offset", 0 },
      { "acc", 0 },
      { "cols[]", "social" },
      { "cols[]", "total" },
      { "cols[]", "percent" },
      { "cols[]", "social_key" },
      { "cols[]", "color" },
      { "dependent_cols[social]", "total" },
      { "dependent_cols[percent]", "total" },
      { "datatitle", "GRID_HEADER_SOCIAL_SPREAD" },
      { "chunking_offset", "0" },
      { "chunking_fields[]", "social" },
      { "chunking_fields[]", "total" },
      { "chunking_fields[]", "percent" },
      { "chunking_fields[]", "social_key" },
      { "chunking_fields[]", "color" }
    ]

    {url, params} 
  end

  defp url(domain, country, :seo_paid) do
    url = "#{@host}/grid/socialspread"

    params = %{
      module: "chart_research_seosem_line",
      action: "seo-paid-visibility",
      dynamicfunction: "std_dyn_func",
      width: 4,
      eventmarker: true,
      url: domain,
      cc: country,
      filter: %{},
      acc: 0
    }

    {url, params}
  end

  defp check_quota(response, :rank) do
    String.contains?(response, "Ihr tägliches Abfragenkontingent ist aufgebraucht")
  end
end
