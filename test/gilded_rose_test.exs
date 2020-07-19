defmodule GildedRoseTest do
  use ExUnit.Case
  alias GildedRose.Item

  doctest GildedRose

  @aged_brie "Aged Brie"
  @backstage_passes "Backstage passes to a TAFKAL80ETC concert"
  @conjured "Conjured Mana Cake"
  @normal "Elixir of the Mongoose"
  @sulfuras "Sulfuras, Hand of Ragnaros"

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

  def item_fixture(@sulfuras, _sell_in, _quality) do
    Item.new(@sulfuras, 0, 80)
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
      state = [item_fixture()]
      agent = GildedRose.new(state)
      assert GildedRose.items(agent) == state
    end
  end

  describe "For all items, `GildedRose.update_quality/1`" do
    test "never assigns a negative value to `:quality`" do
      items = [
        item_fixture(@aged_brie, 2, 0),
        item_fixture(@normal, 5, 7),
        item_fixture(@sulfuras, 0, 80),
        item_fixture(@backstage_passes, 15, 20),
        item_fixture(@conjured, 3, 6)
      ]

      agent = GildedRose.new(items)
      Enum.each(1..20, fn _int -> GildedRose.update_quality(agent) end)

      assert Enum.all?(GildedRose.items(agent), fn %Item{quality: quality} -> quality >= 0 end)
    end
  end

  describe "For all items, except `Sulfuras`, `GildedRose.update_quality/1`" do
    test "decrements `:sell_in` by one" do
      items = [item_fixture(), item_fixture(@aged_brie), item_fixture(@backstage_passes)]
      agent = GildedRose.new(items)
      GildedRose.update_quality(agent)
      items = GildedRose.items(agent)

      assert Enum.all?(items, fn %Item{sell_in: sell_in} -> sell_in == @default_sell_in - 1 end)
    end

    test "permits negative values for `:sell_in`" do
      items = [
        item_fixture(@normal, 1),
        item_fixture(@aged_brie, 2),
        item_fixture(@backstage_passes, 3)
      ]

      agent = GildedRose.new(items)
      Enum.each(1..5, fn _int -> GildedRose.update_quality(agent) end)
      items = GildedRose.items(agent)

      assert Enum.all?(items, fn %Item{sell_in: sell_in} -> sell_in < 0 end)
    end

    test "never increases `:quality` beyond fifty" do
      items = [item_fixture(@aged_brie, 10, 45), item_fixture(@backstage_passes, 10, 45)]
      agent = GildedRose.new(items)
      Enum.each(1..10, fn _int -> GildedRose.update_quality(agent) end)
      items = GildedRose.items(agent)

      assert Enum.all?(items, fn %Item{quality: quality} -> quality == 50 end)
    end
  end

  describe "For `Sulfuras`, `GildedRose.update_quality/1`" do
    test "sustains a constant value of zero for `:sell_in`" do
      items = [item_fixture(@sulfuras)]
      agent = GildedRose.new(items)
      Enum.each(1..5, fn _int -> GildedRose.update_quality(agent) end)

      assert [%Item{sell_in: 0}] = GildedRose.items(agent)
    end

    test "sustains a constant value of eighty for `:quality`" do
      items = [item_fixture(@sulfuras)]
      agent = GildedRose.new(items)
      Enum.each(1..5, fn _int -> GildedRose.update_quality(agent) end)

      assert [%Item{quality: 80}] = GildedRose.items(agent)
    end
  end

  describe "For `Aged Brie`, `GildedRose.update_quality/1`" do
    test "increases `:quality` by one if `:sell_in` is more than zero" do
      items = [item_fixture(@aged_brie, 1, 5)]
      agent = GildedRose.new(items)
      GildedRose.update_quality(agent)

      assert [%Item{quality: 6}] = GildedRose.items(agent)
    end

    test "increases `:quality` by two if `:sell_in` is zero or less" do
      items = [item_fixture(@aged_brie, 0, 0)]
      agent = GildedRose.new(items)
      GildedRose.update_quality(agent)

      assert [%Item{quality: 2}] = GildedRose.items(agent)

      GildedRose.update_quality(agent)

      assert [%Item{quality: 4}] = GildedRose.items(agent)
    end
  end

  describe "For `Backstage passes`, `GildedRose.update_quality/1`" do
    test "increases `:quality` by one when `:sell_in` exceeds ten" do
      items = [item_fixture(@backstage_passes, 11, 5)]
      agent = GildedRose.new(items)
      GildedRose.update_quality(agent)

      assert [%Item{quality: 6}] = GildedRose.items(agent)
    end

    test "increases `:quality` by two when `:sell_in` is ten or less" do
      items = [item_fixture(@backstage_passes, 10, 5)]
      agent = GildedRose.new(items)
      GildedRose.update_quality(agent)

      assert [%Item{quality: 7}] = GildedRose.items(agent)

      items = [item_fixture(@backstage_passes, 9, 5)]
      agent = GildedRose.new(items)
      GildedRose.update_quality(agent)

      assert [%Item{quality: 7}] = GildedRose.items(agent)
    end

    test "increases `:quality` by three when `:sell_in` is five or less" do
      items = [item_fixture(@backstage_passes, 5, 5)]
      agent = GildedRose.new(items)
      GildedRose.update_quality(agent)

      assert [%Item{quality: 8}] = GildedRose.items(agent)

      items = [item_fixture(@backstage_passes, 4, 5)]
      agent = GildedRose.new(items)
      GildedRose.update_quality(agent)

      assert [%Item{quality: 8}] = GildedRose.items(agent)
    end

    test "degrades `:quality` to zero when `:sell_in` is is zero or less" do
      items = [item_fixture(@backstage_passes, 0, 5)]
      agent = GildedRose.new(items)
      GildedRose.update_quality(agent)

      assert [%Item{quality: 0}] = GildedRose.items(agent)

      items = [item_fixture(@backstage_passes, -1, 5)]
      agent = GildedRose.new(items)
      GildedRose.update_quality(agent)

      assert [%Item{quality: 0}] = GildedRose.items(agent)
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
      items = [item_fixture(@normal, 1, 10)]
      agent = GildedRose.new(items)
      GildedRose.update_quality(agent)

      assert [%Item{quality: 9}] = GildedRose.items(agent)
    end

    test "degrades `:quality` by two when `:sell_in` is zero or less" do
      items = [item_fixture(@normal, 0, 10)]
      agent = GildedRose.new(items)
      GildedRose.update_quality(agent)

      assert [%Item{quality: 8}] = GildedRose.items(agent)

      items = [item_fixture(@normal, -1, 10)]
      agent = GildedRose.new(items)
      GildedRose.update_quality(agent)

      assert [%Item{quality: 8}] = GildedRose.items(agent)
    end
  end
end
