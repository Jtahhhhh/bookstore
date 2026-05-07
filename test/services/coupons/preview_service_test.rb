require "test_helper"

module Coupons
  class PreviewServiceTest < ActiveSupport::TestCase
    def setup
      CouponRedemption.delete_all
      Coupon.delete_all

      @order_payload = {
        order_id: 1,
        items: [
          { book_id: 1, title: "Ruby Core", unit_price: "100000", quantity: 2 },
          { book_id: 2, title: "Rails API", unit_price: "150000", quantity: 1 }
        ]
      }
    end

    test "valid percentage coupon returns correct discount" do
      create_coupon!(
        code: "RUBY10",
        discount_type: "percentage",
        discount_value: 10,
        max_discount_amount: nil
      )

      result = PreviewService.new(params("RUBY10")).call

      assert_equal :ok, result[:status]
      assert_equal 350_000.to_d, result[:original_amount]
      assert_equal 35_000.to_d, result[:discount_amount]
      assert_equal 315_000.to_d, result[:final_amount]
    end

    test "max_discount_amount caps percentage discount" do
      create_coupon!(
        code: "RUBY20",
        discount_type: "percentage",
        discount_value: 20,
        max_discount_amount: 50_000
      )

      result = PreviewService.new(params("RUBY20")).call

      assert_equal :ok, result[:status]
      assert_equal 350_000.to_d, result[:original_amount]
      assert_equal 50_000.to_d, result[:discount_amount]
      assert_equal 300_000.to_d, result[:final_amount]
    end

    test "fixed amount coupon works" do
      create_coupon!(
        code: "FIXED30K",
        discount_type: "fixed_amount",
        discount_value: 30_000
      )

      result = PreviewService.new(params("FIXED30K")).call

      assert_equal :ok, result[:status]
      assert_equal 30_000.to_d, result[:discount_amount]
      assert_equal 320_000.to_d, result[:final_amount]
    end

    test "expired coupon returns 422" do
      create_coupon!(
        code: "EXPIRED",
        starts_at: 10.days.ago,
        ends_at: 1.day.ago
      )

      result = PreviewService.new(params("EXPIRED")).call

      assert_equal :unprocessable_entity, result[:status]
      assert_equal "Coupon expired", result[:error]
    end

    test "inactive coupon returns 422" do
      create_coupon!(
        code: "INACTIVE",
        active: false
      )

      result = PreviewService.new(params("INACTIVE")).call

      assert_equal :not_found, result[:status]
      assert_equal "Coupon not found", result[:error]
    end

    test "minimum order amount not met returns 422" do
      create_coupon!(
        code: "MIN500K",
        min_order_amount: 500_000
      )

      result = PreviewService.new(params("MIN500K")).call

      assert_equal :unprocessable_entity, result[:status]
      assert_equal "Order amount does not meet minimum requirement", result[:error]
    end

    private

    def params(code)
      {
        coupon_code: code,
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