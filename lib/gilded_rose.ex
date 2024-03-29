defmodule GildedRose do
  use Agent
  alias GildedRose.Item

  ###
  # Exceptional item types
  ##

  @aged_brie "Aged Brie"
  @backstage_passes "Backstage passes to a TAFKAL80ETC concert"
  @conjured "Conjured Mana Cake"
  @sulfuras "Sulfuras, Hand of Ragnaros"

  ###
  # Quality thresholds.
  #
  # Used by `clamp_quality/1`, which circumscribes values for `:quality` to
  # levels we define here.
  #
  # Excepting `sulfuras`, for which `:quality` is constant (i.e., `80`), the
  # `:quality` for all other items:
  #
  # - Is never negative;
  # - Is never more than fifty.
  ##

  @quality_min 0
  @quality_max 50

  @doc """
  Special types.

  We aggregate and export all exceptional item types to accommodate unit tests.
  """
  def special_types do
    %{
      aged_brie: @aged_brie,
      backstage_passes: @backstage_passes,
      conjured: @conjured,
      sulfuras: @sulfuras
    }
  end

  def default_items do
    [
      %Item{name: "+5 Dexterity Vest", sell_in: 10, quality: 20},
      %Item{name: @aged_brie, sell_in: 2, quality: 0},
      %Item{name: "Elixir of the Mongoose", sell_in: 5, quality: 7},
      %Item{name: @sulfuras, sell_in: 0, quality: 80},
      %Item{name: @backstage_passes, sell_in: 15, quality: 20},
      %Item{name: @conjured, sell_in: 3, quality: 6}
    ]
  end

  @moduledoc """
  New (`Agent` for use with this module).
  """
  @spec new(any()) :: pid()
  def new(items \\ default_items()) do
    {:ok, agent} = Agent.start_link(fn -> items end)
    agent
  end

  def items(agent), do: Agent.get(agent, & &1)

  @moduledoc """
  Update `:quality` (and `:sell_in` on `%Item{}`s contained by `Agent`).

  Provided an `Agent`,

  ## Examples

      iex> agent = GildedRose.new()
      iex> GildedRose.update_quality(agent)
      :ok

  """
  @spec update_quality(pid()) :: :ok
  def update_quality(agent) do
    new_state =
      agent
      |> items()
      |> Enum.map(&put_quality(&1))
      |> Enum.map(&clamp_quality(&1))
      |> Enum.map(&put_sell_in(&1))

    Agent.update(agent, fn _state -> new_state end)
  end

  ###
  # Sulfurus
  ##

  @spec put_quality(%Item{}) :: %Item{}
  defp put_quality(%Item{name: @sulfuras} = item) do
    item
  end

  ###
  # Aged brie
  ##

  defp put_quality(%Item{name: @aged_brie, quality: quality, sell_in: sell_in} = item)
       when sell_in > 0 do
    %{item | quality: quality + 1}
  end

  defp put_quality(%Item{name: @aged_brie, quality: quality} = item) do
    %{item | quality: quality + 2}
  end

  ###
  # Backstage passes
  ##

  defp put_quality(%Item{name: @backstage_passes, quality: quality, sell_in: sell_in} = item)
       when sell_in > 10 do
    %{item | quality: quality + 1}
  end

  defp put_quality(%Item{name: @backstage_passes, quality: quality, sell_in: sell_in} = item)
       when sell_in > 5 do
    %{item | quality: quality + 2}
  end

  defp put_quality(%Item{name: @backstage_passes, quality: quality, sell_in: sell_in} = item)
       when sell_in > 0 do
    %{item | quality: quality + 3}
  end

  defp put_quality(%Item{name: @backstage_passes} = item) do
    %{item | quality: 0}
  end

  ###
  # Conjured items
  ##

  defp put_quality(%Item{name: @conjured, quality: quality, sell_in: sell_in} = item)
       when sell_in > 0 do
    %{item | quality: quality - 2}
  end

  defp put_quality(%Item{name: @conjured, quality: quality} = item) do
    %{item | quality: quality - 4}
  end

  ###
  # Normal items
  ##

  defp put_quality(%Item{quality: quality, sell_in: sell_in} = item) when sell_in > 0 do
    %{item | quality: quality - 1}
  end

  defp put_quality(%Item{quality: quality} = item) do
    %{item | quality: quality - 2}
  end

  ###
  # Helpers and other rules
  ##

  @spec clamp_quality(%Item{}) :: %Item{}
  defp clamp_quality(%Item{name: @sulfuras} = item), do: item

  defp clamp_quality(%Item{quality: quality} = item) do
    quality = quality |> min(@quality_max) |> max(@quality_min)
    %{item | quality: quality}
  end

  @spec put_sell_in(%Item{}) :: %Item{}
  defp put_sell_in(%Item{name: @sulfuras} = item), do: item

  defp put_sell_in(%Item{sell_in: sell_in} = item) do
    %{item | sell_in: sell_in - 1}
  end
end
