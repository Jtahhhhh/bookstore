require "test_helper"

class CouponRedemptionTest < ActiveSupport::TestCase
  test "requires idempotency key" do
    CouponRedemption.delete_all
    Coupon.delete_all
    user = User.create!(
      email: "redemption@example.com",
      password: "password",
      password_confirmation: "password"
    )
    coupon = Coupon.create!(
      code: "EXPIRED10",
      discount_type: "percentage",
      discount_value: 10,
      min_order_amount: 100_000,
      max_discount_amount: 20_000,
      usage_limit: 100,
      used_count: 0,
      starts_at: 10.days.ago,
      ends_at: 1.day.ago,
      active: true
    )

    redemption = coupon.coupon_redemptions.new(
      user_id: user.id,
      order_id: "order-1",
      discount_amount: 12.0,
      original_amount: 12.0,
      final_amount: 12.0
    )

    assert_not redemption.save
  end
end
