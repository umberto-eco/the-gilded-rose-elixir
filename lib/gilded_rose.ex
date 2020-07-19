defmodule GildedRose do
  use Agent
  alias GildedRose.Item

  @aged_brie "Aged Brie"
  @backstage_passes "Backstage passes to a TAFKAL80ETC concert"
  @conjured "Conjured Mana Cake"
  @sulfurus "Sulfuras, Hand of Ragnaros"

  @default_values [
    {"+5 Dexterity Vest", 10, 20},
    {@aged_brie, 2, 0},
    {"Elixir of the Mongoose", 5, 7},
    {@sulfurus, 0, 80},
    {@backstage_passes, 15, 20},
    {@conjured, 3, 6}
  ]

  @default_items Enum.map(@default_values, fn {name, sell_in, quality} ->
                   Item.new(name, sell_in, quality)
                 end)

  def default_items, do: @default_items

  def new(items \\ @default_items) do
    {:ok, agent} = Agent.start_link(fn -> items end)
    agent
  end

  def items(agent), do: Agent.get(agent, & &1)

  def update_quality(agent) do
    for i <- 0..(Agent.get(agent, &length/1) - 1) do
      item = Agent.get(agent, &Enum.at(&1, i))

      item =
        cond do
          item.name != "Aged Brie" && item.name != "Backstage passes to a TAFKAL80ETC concert" ->
            if item.quality > 0 do
              if item.name != "Sulfuras, Hand of Ragnaros" do
                %{item | quality: item.quality - 1}
              else
                item
              end
            else
              item
            end

          true ->
            cond do
              item.quality < 50 ->
                item = %{item | quality: item.quality + 1}

                cond do
                  item.name == "Backstage passes to a TAFKAL80ETC concert" ->
                    item =
                      cond do
                        item.sell_in < 11 ->
                          cond do
                            item.quality < 50 ->
                              %{item | quality: item.quality + 1}

                            true ->
                              item
                          end

                        true ->
                          item
                      end

                    cond do
                      item.sell_in < 6 ->
                        cond do
                          item.quality < 50 ->
                            %{item | quality: item.quality + 1}

                          true ->
                            item
                        end

                      true ->
                        item
                    end

                  true ->
                    item
                end

              true ->
                item
            end
        end

      item =
        cond do
          item.name != "Sulfuras, Hand of Ragnaros" ->
            %{item | sell_in: item.sell_in - 1}

          true ->
            item
        end

      item =
        cond do
          item.sell_in < 0 ->
            cond do
              item.name != "Aged Brie" ->
                cond do
                  item.name != "Backstage passes to a TAFKAL80ETC concert" ->
                    cond do
                      item.quality > 0 ->
                        cond do
                          item.name != "Sulfuras, Hand of Ragnaros" ->
                            %{item | quality: item.quality - 1}

                          true ->
                            item
                        end

                      true ->
                        item
                    end

                  true ->
                    %{item | quality: item.quality - item.quality}
                end

              true ->
                cond do
                  item.quality < 50 ->
                    %{item | quality: item.quality + 1}

                  true ->
                    item
                end
            end

          true ->
            item
        end

      Agent.update(agent, &List.replace_at(&1, i, item))
    end

    :ok
  end
end
