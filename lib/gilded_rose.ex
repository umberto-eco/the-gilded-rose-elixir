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

  @default_values [
    {"+5 Dexterity Vest", 10, 20},
    {@aged_brie, 2, 0},
    {"Elixir of the Mongoose", 5, 7},
    {@sulfuras, 0, 80},
    {@backstage_passes, 15, 20},
    {@conjured, 3, 6}
  ]

  @quality_min 0
  @quality_max 50

  def special_types do
    %{
      aged_brie: @aged_brie,
      backstage_passes: @backstage_passes,
      conjured: @conjured,
      sulfuras: @sulfuras
    }
  end

  def default_items do
    Enum.map(@default_values, fn {name, sell_in, quality} ->
      Item.new(name, sell_in, quality)
    end)
  end

  def new(items \\ default_items()) do
    {:ok, agent} = Agent.start_link(fn -> items end)
    agent
  end

  def items(agent), do: Agent.get(agent, & &1)

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
