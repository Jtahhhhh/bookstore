require "test_helper"

class ReservationItemTest < ActiveSupport::TestCase
  test "quantity must be greater than zero" do
    item = reservation_items(:pending_reservation_item)
    item.quantity = 0

    assert_not item.valid?
    assert_includes item.errors[:quantity], "must be greater than 0"
  end

  test "subtotal must not be negative" do
    item = reservation_items(:pending_reservation_item)
    item.subtotal = -1

    assert_not item.valid?
    assert_includes item.errors[:subtotal], "must be greater than or equal to 0"
  end
end
