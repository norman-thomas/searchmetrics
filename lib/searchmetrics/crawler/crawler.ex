defmodule SearchMetrics.Crawler do
  @moduledoc """
    Implementation of crawler for fetching the searchmetrics page for a given domain
  """

  require Logger

  @host "https://suite.searchmetrics.com"

  @country "DE"
  @metrics [:visibility, :geo, :rank, :social, :visibility_history]

  @spec fetch(String.t(), String.t()) :: keyword()
  def fetch(domain, host \\ @host) do
    for metric <- @metrics do
      # credo:disable-for-next-line Credo.Check.Refactor.PipeChainStart
      {metric, url(host, domain, @country, metric) |> request}
    end
  end

  defp request({url, params}) do
    Logger.debug(fn -> "REQUESTing #{url} with #{inspect(params)}" end)

    %HTTPoison.Response{body: response} =
      HTTPoison.post!(url, params, %{
        "Content-Type" => "application/x-www-form-urlencoded",
        "Cache-Control" => "no-cache"
      })

    response
  end

  defp build_body(kwl) when is_list(kwl) do
    {:form, kwl}
    # |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
    # |> Enum.join("&")
  end

  defp url(host, domain, country, :visibility) do
    url = "#{host}/kpi_research_seosem_trend/organic-visibility-spread"

    params =
      [
        url: domain,
        cc: country,
        filter: "{}",
        type: "",
        link: "",
        acc: ""
      ]
      |> build_body()

    {url, params}
  end

  defp url(host, domain, country, :geo) do
    url = "#{host}/custom-module_research_seosem/geo-visibility"

    params =
      [
        url: domain,
        cc: country,
        filter: "{}",
        type: "",
        link: "",
        acc: 0
      ]
      |> build_body()

    {url, params}
  end

  defp url(host, domain, country, :rank) do
    url = "#{host}/kpi_research_seosem_value/rank-spread"

    params =
      [
        url: domain,
        cc: country,
        filter: "{}",
        type: "",
        link: "",
        acc: 0
      ]
      |> build_body()

    {url, params}
  end

  defp url(host, domain, country, :social) do
    url = "#{host}/grid/socialspread"

    params =
      [
        {"url", domain},
        {"cc", country},
        {"filter", "{}"},
        {"module", "chart_research_seosem_line"},
        {"action", "grid/socialspread"},
        {"offset", 0},
        {"acc", 0},
        {"cols[]", "social"},
        {"cols[]", "total"},
        {"cols[]", "percent"},
        {"cols[]", "social_key"},
        {"cols[]", "color"},
        {"dependent_cols[social]", "total"},
        {"dependent_cols[percent]", "total"},
        {"datatitle", "GRID_HEADER_SOCIAL_SPREAD"},
        {"chunking_offset", "0"},
        {"chunking_fields[]", "social"},
        {"chunking_fields[]", "total"},
        {"chunking_fields[]", "percent"},
        {"chunking_fields[]", "social_key"},
        {"chunking_fields[]", "color"}
      ]
      |> build_body()

    {url, params}
  end

  defp url(host, domain, country, :visibility_history) do
    url = "#{host}/chart_research_seosem_line/seo-paid-visibility"

    params =
      [
        module: "chart_research_seosem_line",
        action: "seo-paid-visibility",
        dynamicfunction: "std_dyn_func",
        width: 4,
        eventmarker: true,
        url: domain,
        cc: country,
        filter: "{}",
        acc: 0
      ]
      |> build_body()

    {url, params}
  end
end
