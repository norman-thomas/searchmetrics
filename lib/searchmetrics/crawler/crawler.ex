defmodule SearchMetrics.Crawler do
  @moduledoc """
    Crawler service which has the ability to fetch the searchmetrics page
    for a given domain
  """

  require Logger

  @url "/de/research?url="

  @doc """
  Load searchmetrics page for a given domain

  ## Parameters

  - `domain`: Domain for which the page should be downloaded

  ## Examples

      iex> SearchMetrics.Crawler.fetch("grin.com")
      "<!DOCTYPE html>..." <> "..."

  """
  @spec fetch(String.t()) :: String.t() | nil
  def fetch(domain) when is_binary(domain) and domain != "" do
    {:ok, session} = Wallaby.start_session()

    result =
      case session |> open_page(domain) do
        {:ok, html} ->
          html

        {:error, reason} ->
          Logger.error("ERROR while opening page: #{reason}, taking screenshot...")
          Wallaby.Browser.take_screenshot(session)
          nil
      end

    :ok = Wallaby.end_session(session)
    result
  end

  defp open_page(session, domain) when is_binary(domain) and domain != "" do
    path = @url <> domain

    html =
      session
      |> Wallaby.Browser.visit(path)
      |> Wallaby.Browser.page_source()

    quota_exceeded = String.contains?(html, "Ihr tägliches Abfragenkontingent ist aufgebraucht")

    case quota_exceeded do
      false -> {:ok, html}
      _ -> {:error, :request_limit_reached}
    end
  end
end
