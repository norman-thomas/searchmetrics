defmodule SearchMetrics do
  @moduledoc """
  Documentation for SearchMetrics.
  """

  import SearchMetrics.Page

  @doc """
  Retrieve searchmetrics data about a given URL

  ## Examples

      iex> SearchMetrics.Page.search("google.com")
      %SearchMetrics.Page{}

  """
  def search(domain) when domain != "" do
    case Wallaby.start_session() do
      {:ok, session} ->
        result =
          session
          |> open_page(domain)
          |> get_visibility(:desktop)
          |> get_visibility(:mobile)
          |> get_mojo(:seo)
          |> get_mojo(:paid)
          |> get_mojo(:link)
          |> get_mojo(:social)

        Wallaby.end_session(session)
        result

      {:error, reason} ->
        IO.puts(:stderr, "ERROR while opening page: #{reason}")
        nil
    end
  end
end
