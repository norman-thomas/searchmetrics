defmodule SearchMetricsTest do
  use ExUnit.Case

  # doctest SearchMetrics

  test "opens page (for google.com)" do
    # {:ok, page} = SearchMetrics.Page.open_page(session, "google.com")
    # assert %SearchMetrics.Page{} = page
  end

  test "get visibility" do
    html = File.read!("test/searchmetrics.html")

    result =
      %SearchMetrics.Page{html: html, domain: "grin.com"}
      |> SearchMetrics.Page.get_visibility(:desktop)
      |> SearchMetrics.Page.get_visibility(:mobile)

    assert %SearchMetrics.Metrics{
             desktop: 13953,
             mobile: 16785,
             seo: nil,
             link: nil,
             paid: nil,
             social: nil
           } == result.metrics
  end

  test "get mojo" do
    html = File.read!("test/searchmetrics.html")

    result =
      %SearchMetrics.Page{html: html, domain: "grin.com"}
      |> SearchMetrics.Page.get_mojo(:seo)
      |> SearchMetrics.Page.get_mojo(:paid)
      |> SearchMetrics.Page.get_mojo(:link)
      |> SearchMetrics.Page.get_mojo(:social)

    assert %SearchMetrics.Metrics{
             desktop: nil,
             mobile: nil,
             seo: 1910,
             link: 2006,
             paid: 0,
             social: 0
           } == result.metrics
  end
end
