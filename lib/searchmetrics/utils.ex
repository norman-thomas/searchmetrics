defmodule SearchMetrics.Utils do
  def deep_get(%{} = m, [h | t]) do
    Map.fetch!(m, h)
    |> deep_get(t)
  end

  def deep_get([_ | _] = m, [h | t]) when is_integer(h) do
    Enum.fetch!(m, h)
    |> deep_get(t)
  end

  def deep_get([_ | _] = m, [h | t]) when is_atom(h) do
    Keyword.fetch!(m, h)
    |> deep_get(t)
  end

  def deep_get(m, []) do
    m
  end
end
