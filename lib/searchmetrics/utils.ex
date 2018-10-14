defmodule SearchMetrics.Utils do
  @moduledoc """
  Collection of helper functions
  """

  @doc """
  Able to walk through a map/list tree and retrieve deeply nested elements

  ## Examples

      iex> data = %{
      iex> name: "Norman",
      iex> city: "Málaga",
      iex> job: %{
      iex>   role: "developer",
      iex>   company: "Open Publishing",
      iex>   since: Date.new(2008, 12, 3),
      iex>   languages: [:elixir, :python, :javascript, :"c++", :sql]
      iex> },
      iex> languages: [
      iex>   german: :native,
      iex>   french: :native,
      iex>   english: :fluent,
      iex>   japanese: :fluent,
      iex>   chinese: :intermediate,
      iex>   creole: :fluent,
      iex>   latin: :forgotten
      iex> ]
      iex> }
      iex> SearchMetrics.Utils.deep_get(data, [:name])
      "Norman"
      iex> SearchMetrics.Utils.deep_get(data, [:job, :role])
      "developer"
      iex> SearchMetrics.Utils.deep_get(data, [:job, :languages, 0])
      :elixir
  """
  def deep_get(%{} = m, [h | t]) do
    m
    |> Map.fetch!(h)
    |> deep_get(t)
  end

  def deep_get([_ | _] = m, [h | t]) when is_integer(h) do
    m
    |> Enum.fetch!(h)
    |> deep_get(t)
  end

  def deep_get([_ | _] = m, [h | t]) when is_atom(h) do
    m
    |> Keyword.fetch!(h)
    |> deep_get(t)
  end

  def deep_get(m, []) do
    m
  end
end
