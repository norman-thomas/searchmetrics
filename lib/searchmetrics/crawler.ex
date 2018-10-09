defmodule SearchMetrics.Crawler do
  @moduledoc """

  """

  use GenServer

  @name __MODULE__
  @url "/de/research?url=<%=domain%>"

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  @impl true
  def init(:ok) do
    {:ok, MapSet.new()}
  end

  def crawl(domain) do
    GenServer.call(@name, {:crawl, domain})
  end

  @impl true
  def handle_call({:crawl, domain}, from, state) do
    parent = self()

    pid =
      spawn(fn ->
        result = search(domain)
        GenServer.call(parent, {:respond, from, result})
      end)

    new_state = MapSet.put(state, {pid, from})
    {:noreply, new_state}
  end

  @impl true
  def handle_call({:respond, to, response}, from, state) do
    send(to, response)
    new_state = MapSet.delete(state, {from, to})
    {:reply, new_state}
  end

  @impl true
  def handle_call(_, _from, _state) do
    {:reply, {:error, :unknown_request}}
  end

  ### Implementation

  @doc """
  Retrieve searchmetrics data about a given URL

  ## Parameters

  - `domain`: Domain for which the searchmetrics should be retrieved

  ## Examples

      iex> SearchMetrics.Crawler.search("grin.com")
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
  @spec search(String.t()) :: String.t() | nil
  def search(domain) when domain != "" do
    {:ok, session} = Wallaby.start_session()

    result =
      case session |> open_page(domain) do
        {:ok, _page} ->
          #result =
          #  page
          #  |> get_visibility(:desktop)
          #  |> get_visibility(:mobile)
          #  |> get_mojo(:seo)
          #  |> get_mojo(:paid)
          #  |> get_mojo(:link)
          #  |> get_mojo(:social)

          Wallaby.Browser.page_source(session)

        {:error, reason} ->
          IO.puts(:stderr, "ERROR while opening page: #{reason}")
          IO.puts("taking screenshot...")
          Wallaby.Browser.take_screenshot(session)
          nil
      end

    Wallaby.end_session(session)
    result
  end

  @doc """
  Opens the searchmetrics page for a given domain, provided a Wallaby session

  ## Parameters

    - `session`: a Wallaby session
    - `domain`: TLD you wish to request

  ## Examples

      iex> SearchMetrics.Page.open_page(session, "google.com")
  """
  @spec open_page(Wallaby.Session.t(), String.t()) :: {:ok, String.t()} | {:error, atom()}
  def open_page(session, domain) when domain != "" do
    path = EEx.eval_string(@url, domain: domain)

    html =
      session
      |> Wallaby.Browser.visit(path)
      |> Wallaby.Browser.page_source()

    unless String.contains?(html, "Ihr tägliches Abfragenkontingent ist aufgebraucht") do
      {:ok, html}
    else
      {:error, :request_limit_reached}
    end
  end
end
