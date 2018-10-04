defmodule SearchMetrics do
  @moduledoc """
  Documentation for SearchMetrics.
  """

  import SearchMetrics.Page

  @doc """
  Retrieve searchmetrics data about a given URL

  ## Examples

      iex> SearchMetrics.search("google.com")
      %SearchMetrics.Page{
        domain: "grin.com",
        html: "<!DOCTYPE html>",
        metrics: %SearchMetrics.Metrics{
          desktop: 13953,
          link: 2006,
          mobile: 16785,
          paid: 0,
          seo: 1910,
          social: 0
        }
      }

  """
  def search(domain) when domain != "" do
    case Wallaby.start_session() do
      {:ok, session} ->
        result =
          case session |> open_page(domain) do
            {:ok, page} ->
              result =
                page
                |> get_visibility(:desktop)
                |> get_visibility(:mobile)
                |> get_mojo(:seo)
                |> get_mojo(:paid)
                |> get_mojo(:link)
                |> get_mojo(:social)

              html = IO.inspect(Wallaby.Browser.page_source(session))
              %SearchMetrics.Page{result | html: html}

            {:error, reason} ->
              IO.puts(:stderr, "ERROR while opening page: #{reason}")
              IO.puts("taking screenshot...")
              Wallaby.Browser.take_screenshot(session)
              nil
          end

        Wallaby.end_session(session)
        result

      {:error, reason} ->
        IO.puts(:stderr, "ERROR while launching Wallaby: #{reason}")
        nil
    end
  end
end
