require "test_helper"

class FlashSaleTest < ActiveSupport::TestCase
   # validates :name, presence: true
  #   validates :start_time, presence: true
  #   validates :end_time, presence: true
  #   validates :status, presence: true, inclusion: { in: %w[active expired] }
  test "end_time must be after start_time" do
    flash_sale = FlashSale.new(
      name: "Test Flash Sale",
      start_time: Time.current,
      end_time: Time.current - 1.hour,
      status: "active"
    )
    assert_not flash_sale.valid?
    
    assert_includes flash_sale.errors[:end_time], "must be after the start time"
  end

  test "flash sale must have a name" do
    flash_sale = FlashSale.new(
      start_time: Time.current,
      end_time: Time.current + 1.hour,
      status: "active"
    )
    assert_not flash_sale.valid?
    
    assert_includes flash_sale.errors[:name], "can't be blank"
  end

  test "status must be either active or expired" do
    flash_sale = FlashSale.new(
      name: "Test Flash Sale",
      start_time: Time.current,
      end_time: Time.current + 1.hour,
      status: "invalid_status"
    )
    assert_not flash_sale.valid?
    
    assert_includes flash_sale.errors[:status], "is not included in the list"
  end
end
