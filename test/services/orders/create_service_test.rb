require "test_helper"

module Orders
  class CreateServiceTest < ActiveSupport::TestCase
      # test "the truth" do
    #   assert true
    # end
    def setup
      OrderItem.delete_all
      Order.delete_all
      Book.delete_all
      Author.delete_all
      @authur = Author.create!(
        name: "Robert C. Martin"
      )
      @book = Book.create!(
        author_id: @authur.id,
        title: "Clean Code",
        price: 100_000,
        stock: 1
      )
      @order_params = {
        idempotency_key: SecureRandom.uuid,
        items: [
          book_id: @book.id,
          quantity: 1
        ]
      }
      @customer_params = {
        customer_name: "Van Thanh",
        customer_email: "thanh@example.com"
      }
    end

    test "happy path creates order" do
     
      coupon_params = {}

      result = Orders::CreateService.new(
        @order_params,
        @customer_params,
        coupon_params
      ).call

      assert_equal :created, result[:status]
    end

    test "happy path creates order with coupon" do
      user = User.create!(
        email: "tak@gmail.com",
        password: "password"
      )
      @coupon = Coupon.create!(
            code: "RUBY20",
            discount_type: "percentage",
            discount_value: 20,
            max_discount_amount: 50000,
            usage_limit: 100,
            used_count: 10,
            starts_at: 1.day.ago,
            ends_at: 7.days.from_now,
            active: true
          )
      coupon_params = {
        coupon_code: "RUBY20",
        user_id: user.id
      }

      result = Orders::CreateService.new(
        @order_params,
        @customer_params,
        coupon_params
      ).call
      if result[:status] != :created
        puts "Error: #{result[:error]}" 
      end
      assert_equal :created, result[:status]
    end

    test "stock is not sufficient" do
      book = Book.create!(
        author_id: @authur.id,
        title: "Clean Code 2",
        price: 100_000,
        stock: 0
      )
      order_params = {
        idempotency_key: SecureRandom.uuid,
        items: [
          book_id: book.id,
          quantity: 12
        ]
      }
      coupon_params = {}

      result = Orders::CreateService.new(
        order_params,
        @customer_params,
        coupon_params
      ).call

      assert_equal :unprocessable_entity, result[:status]
      assert_includes result[:error], "Insufficient stock"

      assert_equal 0, Order.count
      assert_equal 0, OrderItem.count
      assert_equal 1,  @book.reload.stock
    end

    test "book not found" do

      coupon_params = {}
      order_params = {
        idempotency_key: SecureRandom.uuid,
        items: [
          book_id: 0,
          quantity: 1
        ]
      }

      result = Orders::CreateService.new(
        order_params,
        @customer_params,
        coupon_params
      ).call

      assert_equal :not_found, result[:status]
      assert_includes result[:error], "Book not found."

    end

    test "Duplicate order creation" do
      order_params = {
        idempotency_key: "test-duplicate-key",
        items: [
          book_id: @book.id,
          quantity: 1
        ]
      }
      coupon_params = {}
      Order.create!(
        customer_name: @customer_params[:customer_name],
        customer_email: @customer_params[:customer_email],
        idempotency_key: "test-duplicate-key",
        original_amount: 100000,
        total_price: 100000
      )

      result = Orders::CreateService.new(
        order_params,
        @customer_params,
        coupon_params
      ).call

      assert_equal :ok, result[:status]
      assert_includes result[:message], "Duplicate order"
    end

    test "coupon application failure rolls back order creation" do
      @coupon = Coupon.create!(
          code: "RUBY20",
          discount_type: "percentage",
          discount_value: 20,
          max_discount_amount: 50_000,
          usage_limit: 100,
          used_count: 0,
          starts_at: 1.day.ago,
          ends_at: 7.days.from_now,
          active: true
        )
      coupon_params = {
        coupon_code: "RUBY20"
      }

      result = Orders::CreateService.new(
        @order_params,
        @customer_params,
        coupon_params
      ).call

      assert_equal :unprocessable_entity, result[:status]
    end
  end
end