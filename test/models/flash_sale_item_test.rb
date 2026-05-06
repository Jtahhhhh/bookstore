require "test_helper"

class FlashSaleItemTest < ActiveSupport::TestCase
  test "stock must not be negative" do
    item = flash_sale_items(:ruby_sale_item)
    item.stock = -1

    assert_not item.valid?
    assert_includes item.errors[:stock], "must be greater than or equal to 0"
  end

  test "sale price must not be negative" do
    item = flash_sale_items(:ruby_sale_item)
    item.sale_price = -1

    assert_not item.valid?
    assert_includes item.errors[:sale_price], "must be greater than or equal to 0"
  end
end
