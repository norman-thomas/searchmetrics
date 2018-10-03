defmodule SearchMetrics.Page do
  @moduledoc """
  Module for retrieving information from the searchmetrics.com page
  """

  defstruct domain: nil,
            html: nil,
            metrics: %SearchMetrics.Metrics{}

  @url "/de/research?url=<%=domain%>"
  @css_accessor_desktop "#overview .x-kpi.double-ring .competitive > .visibility-part.desktop div:nth-child(3)"
  @css_accessor_mobile "#overview .x-kpi.double-ring .competitive > .visibility-part.mobile div:nth-child(3)"
  @css_accessor_seo "#overview .x-kpi.mojo .infos .text .seo"
  @css_accessor_paid "#overview .x-kpi.mojo .infos .text .paid"
  @css_accessor_link "#overview .x-kpi.mojo .infos .text .link"
  @css_accessor_social "#overview .x-kpi.mojo .infos .text .social"

  @doc """
  Opens the searchmetrics page for a given domain, provided a Wallaby session

  ## Parameters

    - `session`: a Wallaby session
    - `domain`: TLD you wish to request

  ## Examples

      iex> SearchMetrics.Page.open_page(session, "google.com")
  """
  def open_page(session, domain) when domain != "" do
    path = EEx.eval_string(@url, domain: domain)

    html =
      session
      |> Wallaby.Browser.visit(path)

    %SearchMetrics.Page{html: html, domain: domain}
  end

  @doc """
  Get mobility score for `:desktop` or `:mobile`
  """
  def get_visibility(%SearchMetrics.Page{} = page, :desktop),
    do: page |> get_score(:desktop, @css_accessor_desktop)

  def get_visibility(%SearchMetrics.Page{} = page, :mobile),
    do: page |> get_score(:mobile, @css_accessor_mobile)

  defp get_score(%SearchMetrics.Page{html: html} = page, type, selector) do
    {score, _} =
      html
      |> find_html_node(selector)
      |> String.replace(~r/[,\.]/, "")
      |> Integer.parse()

    metrics = page.metrics |> Map.put(type, score)
    %SearchMetrics.Page{page | metrics: metrics}
  end

  @doc """
  Get mojo scores
  """
  def get_mojo(%SearchMetrics.Page{} = page, :seo),
    do: page |> get_mojo(:seo, @css_accessor_seo)

  def get_mojo(%SearchMetrics.Page{} = page, :paid),
    do: page |> get_mojo(:paid, @css_accessor_paid)

  def get_mojo(%SearchMetrics.Page{} = page, :link),
    do: page |> get_mojo(:link, @css_accessor_link)

  def get_mojo(%SearchMetrics.Page{} = page, :social),
    do: page |> get_mojo(:social, @css_accessor_social)

  defp get_mojo(%SearchMetrics.Page{html: html} = page, name, selector) do
    value =
      html
      |> find_html_node(selector)
      |> get_mojo_value

    metrics = page.metrics |> Map.put(name, value)
    %SearchMetrics.Page{page | metrics: metrics}
  end

  defp find_html_node(html, selector) do
    try do
      html
      |> Wallaby.Browser.find(Wallaby.Query.css(selector))
      |> Wallaby.Element.text()
    rescue
      Wallaby.QueryError ->
        IO.puts(:stderr, "Did not find node for #{selector}")
        IO.inspect(html)
        nil
    end
  end

  defp get_mojo_value(text) do
    # match regex, e.g.: "SEO Rank (#1.910)"
    regex = ~r/^[^\(]*\(([^\(\)]+)\)[^\)]*$/

    rank =
      case Regex.scan(regex, text) do
        [] -> nil
        [[_, rank]] -> rank |> String.replace(~r/[\#,\.]/, "") |> Integer.parse()
        _ -> nil
      end

    case rank do
      {score, _} -> score
      _ -> nil
    end
  end
end
