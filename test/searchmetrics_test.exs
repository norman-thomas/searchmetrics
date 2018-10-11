defmodule SearchMetricsTest do
  use ExUnit.Case

  # doctest SearchMetrics

  test "opens page (for google.com)" do
    # {:ok, page} = SearchMetrics.Page.open_page(session, "google.com")
    # assert %SearchMetrics.Page{} = page
  end

  test "get visibility" do
    html = File.read!("test/searchmetrics.html")

    {_, result} =
      SearchMetrics.Parser.get_visibility({html, [domain: "grin.com"]}, [:desktop, :mobile])

    metrics = struct(SearchMetrics.Metrics, result)

    assert metrics == %SearchMetrics.Metrics{
             date: Date.utc_today(),
             domain: "grin.com",
             desktop: 13953,
             mobile: 16785,
             seo: 0,
             link: 0,
             paid: 0,
             social: 0
           }
  end

  test "get mojo" do
    html = File.read!("test/searchmetrics.html")

    {_, result} = SearchMetrics.Parser.get_mojo({html, [domain: "grin.com"]}, [:seo, :link])

    metrics = struct(SearchMetrics.Metrics, result)

    assert metrics == %SearchMetrics.Metrics{
             date: Date.utc_today(),
             domain: "grin.com",
             desktop: 0,
             mobile: 0,
             seo: 1910,
             link: 2006,
             paid: 0,
             social: 0
           }
  end

  test "get metrics" do
    html = File.read!("test/searchmetrics.html")

    metrics = SearchMetrics.Parser.get_metrics("grin.com", html)

    assert metrics == %SearchMetrics.Metrics{
             date: Date.utc_today(),
             domain: "grin.com",
             desktop: 13953,
             mobile: 16785,
             seo: 1910,
             link: 2006,
             paid: 0,
             social: 0
           }
  end
end
