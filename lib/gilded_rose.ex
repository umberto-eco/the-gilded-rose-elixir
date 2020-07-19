defmodule GildedRose do
  use Agent
  alias GildedRose.Item

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

  # def update_quality(agent) do
  #   for i <- 0..(Agent.get(agent, &length/1) - 1) do
  #     item = Agent.get(agent, &Enum.at(&1, i))

  #     item =
  #       cond do
  #         item.name != "Aged Brie" && item.name != "Backstage passes to a TAFKAL80ETC concert" ->
  #           if item.quality > 0 do
  #             if item.name != "Sulfuras, Hand of Ragnaros" do
  #               %{item | quality: item.quality - 1}
  #             else
  #               item
  #             end
  #           else
  #             item
  #           end

  #         true ->
  #           cond do
  #             item.quality < 50 ->
  #               item = %{item | quality: item.quality + 1}

  #               cond do
  #                 item.name == "Backstage passes to a TAFKAL80ETC concert" ->
  #                   item =
  #                     cond do
  #                       item.sell_in < 11 ->
  #                         cond do
  #                           item.quality < 50 ->
  #                             %{item | quality: item.quality + 1}

  #                           true ->
  #                             item
  #                         end

  #                       true ->
  #                         item
  #                     end

  #                   cond do
  #                     item.sell_in < 6 ->
  #                       cond do
  #                         item.quality < 50 ->
  #                           %{item | quality: item.quality + 1}

  #                         true ->
  #                           item
  #                       end

  #                     true ->
  #                       item
  #                   end

  #                 true ->
  #                   item
  #               end

  #             true ->
  #               item
  #           end
  #       end

  #     item =
  #       cond do
  #         item.name != "Sulfuras, Hand of Ragnaros" ->
  #           %{item | sell_in: item.sell_in - 1}

  #         true ->
  #           item
  #       end

  #     item =
  #       cond do
  #         item.sell_in < 0 ->
  #           cond do
  #             item.name != "Aged Brie" ->
  #               cond do
  #                 item.name != "Backstage passes to a TAFKAL80ETC concert" ->
  #                   cond do
  #                     item.quality > 0 ->
  #                       cond do
  #                         item.name != "Sulfuras, Hand of Ragnaros" ->
  #                           %{item | quality: item.quality - 1}

  #                         true ->
  #                           item
  #                       end

  #                     true ->
  #                       item
  #                   end

  #                 true ->
  #                   %{item | quality: item.quality - item.quality}
  #               end

  #             true ->
  #               cond do
  #                 item.quality < 50 ->
  #                   %{item | quality: item.quality + 1}

  #                 true ->
  #                   item
  #               end
  #           end

  #         true ->
  #           item
  #       end

  #     Agent.update(agent, &List.replace_at(&1, i, item))
  #   end

  #   :ok
  # end

  def update_quality(agent) do
    new_state =
      agent
      |> items()
      |> Enum.map(&put_quality(&1))
      |> Enum.map(&clamp_quality(&1))
      |> Enum.map(&put_sell_in(&1))

    Agent.update(agent, fn _state -> new_state end)
  end

  defp put_quality(%Item{name: @sulfuras} = item) do
    item
  end

  defp put_quality(%Item{name: @aged_brie, quality: quality, sell_in: sell_in} = item)
       when sell_in > 0 do
    %{item | quality: quality + 1}
  end

  defp put_quality(%Item{name: @aged_brie, quality: quality} = item) do
    %{item | quality: quality + 2}
  end

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

  defp put_quality(%Item{name: @conjured, quality: quality, sell_in: sell_in} = item)
       when sell_in > 0 do
    %{item | quality: quality - 2}
  end

  defp put_quality(%Item{name: @conjured, quality: quality} = item) do
    %{item | quality: quality - 4}
  end

  defp put_quality(%Item{quality: quality, sell_in: sell_in} = item) when sell_in > 0 do
    %{item | quality: quality - 1}
  end

  defp put_quality(%Item{quality: quality} = item) do
    %{item | quality: quality - 2}
  end

  defp clamp_quality(%Item{name: @sulfuras} = item), do: item

  defp clamp_quality(%Item{quality: quality} = item) do
    quality = quality |> min(@quality_max) |> max(@quality_min)
    %{item | quality: quality}
  end

  defp put_sell_in(%Item{name: @sulfuras} = item), do: item

  defp put_sell_in(%Item{sell_in: sell_in} = item) do
    %{item | sell_in: sell_in - 1}
  end
end
