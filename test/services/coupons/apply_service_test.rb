require "test_helper"

module Coupons
  class ApplyServiceTest < ActiveSupport::TestCase
    def setup
      CouponRedemption.delete_all
      Coupon.delete_all
      OrderItem.delete_all
      Order.delete_all
      Book.delete_all
      User.delete_all
      Author.delete_all
      @authur = Author.create!(
        name: "Robert C. Martin"
      )
      @user = User.create!(
        email: "coupon-apply@example.com",
        password: "password",
        password_confirmation: "password"
      )

      @book_1 = Book.create!(
        author_id: @authur.id,
        title: "Ruby Core",
        price: 100_000,
        stock: 10
      )

      @book_2 = Book.create!(
        author_id: @authur.id,
        title: "Rails API",
        price: 150_000,
        stock: 10
      )

      @order = Order.create!(
        customer_name: "Coupon User",
        customer_email: "coupon-apply@example.com",
        idempotency_key: "order-1001",
        original_amount: 350_000,
        total_price: 350_000
      )

      @order.order_items.create!(
        book: @book_1,
        quantity: 2,
        unit_price: 100_000,
        subtotal: 200_000
      )

      @order.order_items.create!(
        book: @book_2,
        quantity: 1,
        unit_price: 150_000,
        subtotal: 150_000
      )

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
        result = ApplyService.new(params, @order).call

        assert_equal :created, result[:status]
        assert_equal "Coupon applied successfully", result[:message]
        assert_equal 350_000.to_d, result[:original_amount]
        assert_equal 50_000.to_d, result[:discount_amount]
        assert_equal 300_000.to_d, result[:final_amount]
      end
    end

    test "valid apply increments used_count by 1" do
      assert_difference -> { @coupon.reload.used_count }, 1 do
        ApplyService.new(params, @order).call
      end
    end

    test "retry same idempotency_key does not increment used_count again" do
      first_result = ApplyService.new(params, @order).call
      assert_equal :created, first_result[:status]

      assert_no_difference -> { @coupon.reload.used_count } do
        second_result = ApplyService.new(params, @order).call

        assert_equal :ok, second_result[:status]
        assert_equal "Coupon already applied", second_result[:message]
      end

      assert_equal 1, CouponRedemption.count
    end

    test "usage_limit reached returns 422" do
      @coupon.update!(usage_limit: 1, used_count: 1)

      assert_no_difference "CouponRedemption.count" do
        result = ApplyService.new(params, @order).call

        assert_equal :unprocessable_entity, result[:status]
        assert_equal "Coupon usage limit reached", result[:error]
      end
    end

    private

    def params(idempotency_key: "apply-order-1001-ruby20")
      {
        coupon_code: "RUBY20",
        user_id: @user.id
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
