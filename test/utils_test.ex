defmodule UtilsTest do
    use ExUnit.Case, async: true
  
    doctest SearchMetrics.Utils
  
    test "gets the sub-element value from a dict" do
      data = %{}
  
      url = endpoint_url(bypass.port)
      result = SearchMetrics.Crawler.fetch("grin.com", url)
    end
  end
  