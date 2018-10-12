defmodule SearchMetrics.Parser do
  @moduledoc """
  Module for scraping information from the searchmetrics.com page
  """

  use Timex

  @css_accessor_desktop ".visibility-part.desktop div:nth-child(3)"
  @css_accessor_mobile ".visibility-part.mobile div:nth-child(3)"

  @css_accessor_seo ".infos .text .seo"
  @css_accessor_paid ".infos .text .paid"
  @css_accessor_link ".infos .text .link"
  @css_accessor_social ".infos .text .social"

  @css_accessor_geo "table tbody tr"
  @css_accessor_geo_country "td[data-country] div:first-child"
  @css_accessor_geo_visibility "td.left span"
  @css_accessor_geo_percentage "td.right"

  # @metrics [:visibility, :geo, :rank, :visibility_history]

  def parse([{k, v} | t] = data) do
    [{k, parse(v, k)} | parse(t)]
  end

  def parse([]) do
    []
  end

  @doc """
  Extracts the metrics from a given searchmetrics HTML page
  """
  @spec parse(String.t(), atom()) :: keyword()
  def parse(html, :visibility) do
    [
      get_visibility(html, :desktop, @css_accessor_desktop),
      get_visibility(html, :mobile, @css_accessor_mobile)
    ]
  end

  def parse(html, :rank) do
    [
      get_rank(html, :seo, @css_accessor_seo),
      get_rank(html, :paid, @css_accessor_paid),
      get_rank(html, :link, @css_accessor_link),
      get_rank(html, :social, @css_accessor_social)
    ]
  end

  def parse(json, :social) do
    {:ok, data} = Poison.decode(json)

    data
    |> Map.fetch!("rows")
    |> Enum.reject(&(Enum.fetch!(&1, 1) == 0))
    |> Enum.map(&parse_social/1)
  end

  def parse(html, :geo) do
    Floki.find(html, @css_accessor_geo)
    |> Enum.map(&parse_geo/1)
  end

  def parse(json, :visibility_history) do
    {:ok, data} = Poison.decode(json)

    date_path = ["data", "chart", "xAxis", "categories"]
    value_path = ["data", "chart", "series", 0, "data"]

    dates =
      deep_get(data, date_path)
      |> Enum.map(&parse_date/1)

    values =
      deep_get(data, value_path)
      |> Enum.map(&Map.fetch!(&1, "y"))

    Enum.zip(dates, values)
  end

  defp deep_get(%{} = m, [h | t]) do
    Map.fetch!(m, h)
    |> deep_get(t)
  end

  defp deep_get([_ | _] = m, [h | t]) when is_integer(h) do
    Enum.fetch!(m, h)
    |> deep_get(t)
  end

  defp deep_get(m, []) do
    m
  end

  defp parse_date(date_str) do
    {:ok, datetime} =
      cond do
        String.contains?(date_str, "/") -> Timex.parse(date_str, "{0M}/{0D}/{YYYY}")
        String.contains?(date_str, ".") -> Timex.parse(date_str, "{0D}.{0M}.{YYYY}")
        String.contains?(date_str, "-") -> Timex.parse(date_str, "{YYYY}-{0M}-{0D}")
        true -> nil
      end

    NaiveDateTime.to_date(datetime)
  end

  defp parse_social([platform, amount, percentage, platform_code | _]) do
    [
      platform: platform,
      platform_code: platform_code,
      amount: amount,
      percent: percentage
    ]
  end

  defp parse_geo(row) do
    [
      get_geo(row, :country, @css_accessor_geo_country, fn val -> val end),
      get_geo(row, :visibility, @css_accessor_geo_visibility, &get_numeric_value/1),
      get_geo(row, :percent, @css_accessor_geo_percentage, &get_percent_value/1)
    ]
  end

  defp get_geo(html, tag, selector, value_func) do
    value =
      html
      |> find_html_node(selector)
      |> value_func.()

    {tag, value}
  end

  defp get_score(html, selector, value_func) do
    html
    |> find_html_node(selector)
    |> value_func.()
  end

  defp get_visibility(html, tag, selector) do
    value =
      html
      |> get_score(selector, &get_numeric_value/1)

    {tag, value}
  end

  defp get_rank(html, tag, selector) do
    value =
      html
      |> get_score(selector, &get_rank_value/1)

    {tag, value}
  end

  defp get_percent_value(text) when is_binary(text) and byte_size(text) > 0 do
    {result, _} =
      text
      |> String.replace(",", ".")
      |> Float.parse()

    result
  end

  defp get_numeric_value(text) when is_binary(text) and byte_size(text) > 0 do
    {result, _} =
      text
      |> String.replace(~r/[,\.]/, "")
      |> Integer.parse()

    result
  end

  defp get_rank_value(text) do
    # match regex, e.g.: "SEO Rank (#1.910)"
    regex = ~r/^[^\(]*\(\#([^\(\)]+)\)[^\)]*$/

    case Regex.scan(regex, text) do
      [[_, rank]] ->
        rank
        |> get_numeric_value

      _ ->
        0
    end
  end

  defp find_html_node(html, selector) do
    html
    |> Floki.find(selector)
    |> Floki.text()
  end
end
