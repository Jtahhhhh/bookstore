require "test_helper"

class FlashSaleItemTest < ActiveSupport::TestCase
  test "quantity must be greater than or equal to 0" do
    item = ReservationItem.new(
      quantity: 0,
      unit_price: 100,
      subtotal: 0
    )

    assert_not item.valid?
    
    assert_includes item.errors[:quantity], "must be greater than 0"
  end
end
