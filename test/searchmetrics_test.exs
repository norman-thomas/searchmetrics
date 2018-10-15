defmodule SearchMetricsTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  defp endpoint_url(port), do: "http://localhost:#{port}"

  def fake_response(url) do
    filename =
      case url do
        "/kpi_research_seosem_trend/organic-visibility-spread" ->
          "organic-visibility-spread.html"

        "/custom-module_research_seosem/geo-visibility" ->
          "geo-visibility.html"

        "/kpi_research_seosem_value/rank-spread" ->
          "rank-spread.html"

        "/grid/socialspread" ->
          "social-spread.json"

        "/chart_research_seosem_line/seo-paid-visibility" ->
          "seo-paid-visibility.json"

        _ ->
          nil
      end

    File.read!("samples/" <> filename)
  end

  def setup_fake_responses(bypass) do
    Bypass.expect(
      bypass,
      fn conn ->
        response = fake_response(conn.request_path)
        Plug.Conn.resp(conn, 200, response)
      end
    )
  end

  test "fetches all data", %{bypass: bypass} do
    setup_fake_responses(bypass)

    url = endpoint_url(bypass.port)
    result = SearchMetrics.Crawler.fetch("grin.com", url)

    assert length(result) == length([:visibility, :geo, :rank, :social, :visibility_history])

    result
    |> Keyword.values()
    |> Enum.each(fn item ->
      assert String.length(item) > 100
    end)
  end

  test "parses the data correctly", %{bypass: bypass} do
    setup_fake_responses(bypass)

    url = endpoint_url(bypass.port)
    result = SearchMetrics.Crawler.fetch("grin.com", url)
  end
end
