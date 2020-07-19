defmodule GildedRoseTest do
  use ExUnit.Case
  alias GildedRose.Item

  doctest GildedRose

  # @default_items [
  #   %Item{name: "+5 Dexterity Vest", sell_in: 10, quality: 20},
  #   %Item{name: "Aged Brie", sell_in: 2, quality: 0},
  #   %Item{name: "Elixir of the Mongoose", sell_in: 5, quality: 7},
  #   %Item{name: "Sulfuras, Hand of Ragnaros", sell_in: 0, quality: 80},
  #   %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 15, quality: 20},
  #   %Item{name: "Conjured Mana Cake", sell_in: 3, quality: 6}
  # ]

  @aged_brie "Aged Brie"
  @backstage_passes "Backstage passes to a TAFKAL80ETC concert"
  @conjured "Conjured Mana Cake"
  @normal "Elixir of the Mongoose"
  @sulfurus "Sulfuras, Hand of Ragnaros"

  @default_sell_in 15
  @default_quality 20

  def item_fixture(type \\ @normal, sell_in \\ @default_sell_in, quality \\ @default_quality)

  def item_fixture(@aged_brie, sell_in, quality) do
    Item.new(@aged_brie, sell_in, quality)
  end

  def item_fixture(@backstage_passes, sell_in, quality) do
    Item.new(@backstage_passes, sell_in, quality)
  end

  def item_fixture(@conjured, sell_in, quality) do
    Item.new(@conjured, sell_in, quality)
  end

  def item_fixture(@sulfurus, _sell_in, _quality) do
    Item.new(@sulfurus, 0, 80)
  end

  def item_fixture(name, sell_in, quality) do
    Item.new(name, sell_in, quality)
  end

  test "interface specification" do
    gilded_rose = GildedRose.new()
    [%GildedRose.Item{} | _] = GildedRose.items(gilded_rose)
    assert :ok == GildedRose.update_quality(gilded_rose)
  end

  describe "`GildedRose.new/0`" do
    test "returns a PID" do
      assert is_pid(GildedRose.new())
    end

    test "stores, by default, a list of `Item`s derived from `@default_items`" do
      items = GildedRose.default_items()
      assert GildedRose.items(GildedRose.new()) == items
    end
  end

  describe "GildedRose.new/1" do
    test "supports passage of custom state as an argument" do
      state = [item_fixture()]
      agent = GildedRose.new(state)
      assert GildedRose.items(agent) == state
    end
  end

  describe "`GildedRose.items/1`" do
    test "returns a copy of the `Agent`'s state'" do
    end
  end

  describe "For all items, `GildedRose.update_quality/1`" do
    test "never assigns a negative value to `:quality`" do
    end
  end

  describe "For all items, except `Sulfuras`, `GildedRose.update_quality/1`" do
    test "decrements `:sell_in` by one" do
    end

    test "permits negative values for `:sell_in`" do
    end

    test "never increases `:quality` beyond fifty" do
    end
  end

  describe "For `Sulfuras`, `GildedRose.update_quality/1`" do
    test "sustains a constant value of zero for `:sell_in`" do
    end

    test "sustains a constant value of eighty for `:quality`" do
    end
  end

  describe "For `Aged Brie`, `GildedRose.update_quality/1`" do
    test "increases `:quality` by one if `:sell_in` is more than zero" do
    end

    test "increases `:quality` by two if `:sell_in` is zero or less" do
    end
  end

  describe "For `Backstage passes`, `GildedRose.update_quality/1`" do
    test "increases `:quality` by one when `:sell_in` exceeds ten" do
    end

    test "increases `:quality` by two when `:sell_in` is ten or less" do
    end

    test "increases `:quality` by three when `:sell_in` is five or less" do
    end

    test "degrades `:quality` to zero when `:sell_in` is is zero or less" do
    end
  end

  describe "For `Conjured items`, `GildedRose.update_quality/1`" do
    test "degrades `:quality` by two when `:sell_in` more than zero" do
    end

    test "degrades `:quality` by four when `:sell_in` is zero or less" do
    end
  end

  describe "For all normal items, `GildedRose.update_quality/1`" do
    test "degrades `:quality` by one when `:sell_in` is more than zero" do
    end

    test "degrades `:quality` by two when `:sell_in` is zero or less" do
    end
  end
end
