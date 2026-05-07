require "test_helper"

class CouponRedemptionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "CouponRedemption requires idempotency_key" do
      author = Author.create!(
        name: "Test Author",
        bio: "Seed author"
      )

      ruby_book = Book.create!(
        author: author,
        title: "Ruby Core",
        description: "Ruby programming book",
        price: 100_000,
        stock: 50,
        published: true
      )

      rails_book = Book.create!(
        author: author,
        title: "Rails API",
        description: "Rails API book",
        price: 150_000,
        stock: 30,
        published: true
      )

      category = Category.create!(
        name: "Programming",
        slug: "programming"
      )

      BookCategory.create!(book: ruby_book, category: category)
      BookCategory.create!(book: rails_book, category: category)

      order = Order.create!(
        customer_name: "User One",
        customer_email: "user1@example.com",
        status: "pending",
        total_price: 350_000
      )

      OrderItem.create!(
        order: order,
        book: ruby_book,
        unit_price: 100_000,
        quantity: 2,
        subtotal: 200_000
      )
      cp = Coupon.create!(
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
      order(column: :desc)
      re = cp.coupon_redemptions.create!(
            user_id: 1
            order_id: order.id,
            discount_amount: 12.0,
            original_amount: 12.0,
            final_amount: 12.0,
          )
      assert_not re.save
  end
end
