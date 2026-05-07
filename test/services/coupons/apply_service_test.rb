require "test_helper"

module Coupons
  class ApplyServiceTest < ActiveSupport::TestCase
    def setup
      CouponRedemption.delete_all
      Coupon.delete_all

      @order_payload = {
        order_id: "order_1001",
        items: [
          { book_id: 1, title: "Ruby Core", unit_price: "100000", quantity: 2 },
          { book_id: 2, title: "Rails API", unit_price: "150000", quantity: 1 }
        ]
      }

      @coupon = create_coupon!(
        code: "RUBY20",
        discount_type: "percentage",
        discount_value: 20,
        max_discount_amount: 50_000,
        usage_limit: 100,
        used_count: 0
      )
    end

    test "valid apply creates redemption" do
      assert_difference "CouponRedemption.count", 1 do
        result = ApplyService.new(params).call

        assert_equal :created, result[:status]
        assert_equal "Coupon applied successfully", result[:message]
        assert_equal 350_000.to_d, result[:original_amount]
        assert_equal 50_000.to_d, result[:discount_amount]
        assert_equal 300_000.to_d, result[:final_amount]
      end
    end

    test "valid apply increments used_count by 1" do
      assert_difference -> { @coupon.reload.used_count }, 1 do
        ApplyService.new(params).call
      end
    end

    test "retry same idempotency_key does not increment used_count again" do
      first_result = ApplyService.new(params(idempotency_key: "same-key")).call
      assert_equal :created, first_result[:status]

      assert_no_difference -> { @coupon.reload.used_count } do
        second_result = ApplyService.new(params(idempotency_key: "same-key")).call

        assert_equal :ok, second_result[:status]
        assert_equal "Coupon already applied", second_result[:message]
      end

      assert_equal 1, CouponRedemption.count
    end

    test "usage_limit reached returns 422" do
      @coupon.update!(usage_limit: 1, used_count: 1)

      assert_no_difference "CouponRedemption.count" do
        result = ApplyService.new(params).call

        assert_equal :unprocessable_entity, result[:status]
        assert_equal "Coupon usage limit reached", result[:error]
      end
    end

    test "same coupon user order cannot redeem twice" do
      first_result = ApplyService.new(params(idempotency_key: "key-1")).call
      assert_equal :created, first_result[:status]

      assert_no_difference "CouponRedemption.count" do
        result = ApplyService.new(params(idempotency_key: "key-2")).call

        assert_equal :unprocessable_entity, result[:status]
      end
    end

    private

    def params(idempotency_key: "apply-order-1001-ruby20")
      {
        idempotency_key: idempotency_key,
        coupon_code: "RUBY20",
        user_id: "user_1",
        order: @order_payload
      }
    end

    def create_coupon!(attrs = {})
      Coupon.create!(
        {
          code: "TEST",
          discount_type: "percentage",
          discount_value: 10,
          min_order_amount: 100_000,
          max_discount_amount: nil,
          usage_limit: 100,
          used_count: 0,
          starts_at: 1.day.ago,
          ends_at: 7.days.from_now,
          active: true
        }.merge(attrs)
      )
    end
  end
end