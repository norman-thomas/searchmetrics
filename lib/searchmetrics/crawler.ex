defmodule SearchMetrics.Crawler do
  @moduledoc """
    Crawler service which has the ability to fetch the searchmetrics page
    for a given domain
  """

  use GenServer
  require Logger

  @name __MODULE__
  @url "/de/research?url=<%=domain%>"

  ### Client Interface ###

  @spec start_link(any()) :: GenEvent.on_start()
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  @spec crawl(String.t()) :: String.t() | nil
  def crawl(domain) do
    # 15 sec timeout
    GenServer.call(@name, {:crawl, domain}, 15_000)
  end

  ### Callbacks ###

  @impl true
  def init(:ok) do
    Logger.debug("starting SearchMetrics.Crawler process...")
    {:ok, []}
  end

  @impl true
  def handle_call({:crawl, domain}, from, state) do
    parent = self()

    spawn(fn ->
      result = fetch(domain)
      GenServer.call(parent, {:respond, from, result})
    end)

    {:noreply, state}
  end

  @impl true
  def handle_call({:respond, to, response}, _from, state) do
    GenServer.reply(to, response)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(_, _from, state) do
    {:reply, {:error, :unknown_request}, state}
  end

  ### Implementation ###

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

        # result =
        #  page
        #  |> get_visibility(:desktop)
        #  |> get_visibility(:mobile)
        #  |> get_mojo(:seo)
        #  |> get_mojo(:paid)
        #  |> get_mojo(:link)
        #  |> get_mojo(:social)

        {:error, reason} ->
          Logger.error("ERROR while opening page: #{reason}, taking screenshot...")
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
  def open_page(session, domain) when is_binary(domain) and domain != "" do
    path = EEx.eval_string(@url, domain: domain)

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
