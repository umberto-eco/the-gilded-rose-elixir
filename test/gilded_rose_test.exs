defmodule GildedRoseTest do
  use ExUnit.Case
  doctest GildedRose

  test "interface specification" do
    gilded_rose = GildedRose.new()
    [%GildedRose.Item{} | _] = GildedRose.items(gilded_rose)
    assert :ok == GildedRose.update_quality(gilded_rose)
  end

  describe "`GildedRose.new/0`" do
    test "returns a PID" do
    end

    test "stores, by default, a list of `Item`s derived from `@default_items`" do
    end
  end

  describe "GildedRose.new/1" do
    test "supports passage of custom state as an argument" do
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
