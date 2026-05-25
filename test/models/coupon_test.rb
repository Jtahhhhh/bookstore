require "test_helper"

class CouponTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "Coupon requires code" do 
    cp = Coupon.new(
      discount_type: "percentage",
      discount_value: 20,
      min_order_amount: 100_000,
      max_discount_amount: 50_000,
      usage_limit: 100,
      used_count: 0,
      starts_at: 1.day.ago,
      ends_at: 7.days.from_now,
      active: true
    )
    assert_not cp.save
  end

  test "Coupon discount_type must be percentage/fixed_amount" do
    cp = Coupon.new(
      code: "123",
      discount_type: "paid",
      discount_value: -5,
      min_order_amount: 100_000,
      max_discount_amount: 50_000,
      usage_limit: 100,
      used_count: 0,
      starts_at: 1.day.ago,
      ends_at: 7.days.from_now,
      active: true
    )
    assert_not cp.save
  end

  test "Coupon discount_value must be > 0" do
    cp = Coupon.new(
      code: "123",
      discount_type: "percentage",
      discount_value: -5,
      min_order_amount: 100_000,
      max_discount_amount: 50_000,
      usage_limit: 100,
      used_count: 0,
      starts_at: 1.day.ago,
      ends_at: 7.days.from_now,
      active: true
    )
    assert_not cp.save
  end

  test "Coupon used_count must be >= 0" do
    cp = Coupon.new(
      code: "123",
      discount_type: "percentage",
      discount_value: 5,
      min_order_amount: 100_000,
      max_discount_amount: 50_000,
      usage_limit: 100,
      used_count: -10,
      starts_at: 1.day.ago,
      ends_at: 7.days.from_now,
      active: true
    )
    assert_not cp.save
  end

  
end
