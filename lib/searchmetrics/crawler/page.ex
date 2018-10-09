defmodule SearchMetrics.Page do
  @moduledoc """
  Module for retrieving information from the searchmetrics.com page
  """

  require Logger

  defstruct html: nil,
            metrics: %SearchMetrics.Metrics{}

  @type t :: %SearchMetrics.Page{
          html: String.t() | nil,
          metrics: SearchMetrics.Metrics.t()
        }

  @css_accessor_desktop "#overview .x-kpi.double-ring .competitive > .visibility-part.desktop div:nth-child(3)"
  @css_accessor_mobile "#overview .x-kpi.double-ring .competitive > .visibility-part.mobile div:nth-child(3)"
  @css_accessor_seo "#overview .x-kpi.mojo .infos .text .seo"
  @css_accessor_paid "#overview .x-kpi.mojo .infos .text .paid"
  @css_accessor_link "#overview .x-kpi.mojo .infos .text .link"
  @css_accessor_social "#overview .x-kpi.mojo .infos .text .social"

  def get_metrics(html, domain) do
    values =
      {html, [domain: domain]}
      |> get_visibility([:desktop, :mobile])
      |> get_mojo([:seo, :paid, :link, :social])
      |> elem(1)

    struct!(SearchMetrics.Metrics, values)
  end

  defp get_values({html, metrics}, [_ | _] = facets, func) do
    new_metrics =
      facets
      |> Enum.map(fn facet -> func.(html, facet) end)
      |> Enum.map(&elem(&1, 1))
      |> Kernel.++(metrics)

    {html, new_metrics}
  end

  def get_visibility({html, metrics}, [_ | _] = platforms) when is_list(metrics) do
    get_values({html, metrics}, platforms, &get_visibility/2)
  end

  @doc """
  Get mobility score for `:desktop` or `:mobile`
  """
  @spec get_visibility(String.t(), atom()) :: {String.t(), {atom(), integer}}
  def get_visibility(html, :desktop),
    do: html |> get_score(:desktop, @css_accessor_desktop)

  def get_visibility(html, :mobile),
    do: html |> get_score(:mobile, @css_accessor_mobile)

  defp get_score(html, type, selector) do
    {score, _} =
      html
      |> find_html_node(selector)
      |> String.replace(~r/[,\.]/, "")
      |> Integer.parse()

    {html, {type, score}}
  end

  def get_mojo({html, metrics}, [_ | _] = aspects) when is_list(metrics) do
    get_values({html, metrics}, aspects, &get_mojo/2)
  end

  @doc """
  Get mojo scores for `:seo`, `:paid`, `:link`, `:social`
  """
  @spec get_mojo(String.t(), atom()) :: {String.t(), {atom(), integer}}
  def get_mojo(html, :seo), do: html |> get_mojo(:seo, @css_accessor_seo)
  def get_mojo(html, :paid), do: html |> get_mojo(:paid, @css_accessor_paid)
  def get_mojo(html, :link), do: html |> get_mojo(:link, @css_accessor_link)
  def get_mojo(html, :social), do: html |> get_mojo(:social, @css_accessor_social)

  @spec get_mojo(String.t(), atom(), String.t()) :: {String.t(), {atom(), integer}}
  defp get_mojo(html, name, selector) do
    value =
      html
      |> find_html_node(selector)
      |> get_mojo_value

    {html, {name, value}}
  end

  defp find_html_node(html, selector) do
    html
    |> Floki.find(selector)
    |> Floki.text()
  end

  @spec get_mojo_value(String.t()) :: integer
  defp get_mojo_value(text) do
    # match regex, e.g.: "SEO Rank (#1.910)"
    regex = ~r/^[^\(]*\(([^\(\)]+)\)[^\)]*$/

    case Regex.scan(regex, text) do
      [[_, rank]] -> rank |> String.replace(~r/[\#,\.]/, "") |> Integer.parse() |> elem(0)
      _ -> 0
    end
  end
end
