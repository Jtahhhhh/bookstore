# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# frozen_string_literal: true

puts "Seeding data..."

CouponRedemption.delete_all
PaymentEvent.delete_all
Payment.delete_all
LedgerEntry.delete_all
Wallet.delete_all
User.delete_all
ReservationItem.delete_all
Reservation.delete_all
FlashSaleItem.delete_all
FlashSale.delete_all
OrderItem.delete_all
Order.delete_all
BookCategory.delete_all
Book.delete_all
Category.delete_all
Author.delete_all
Coupon.delete_all

user = User.create!(
  email: "user1@example.com",
  password: "password",
  password_confirmation: "password"
)

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

OrderItem.create!(
  order: order,
  book: rails_book,
  unit_price: 150_000,
  quantity: 1,
  subtotal: 150_000
)

Coupon.create!(
  code: "RUBY20",
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

Coupon.create!(
  code: "FIXED30K",
  discount_type: "fixed_amount",
  discount_value: 30_000,
  min_order_amount: 100_000,
  max_discount_amount: nil,
  usage_limit: 100,
  used_count: 0,
  starts_at: 1.day.ago,
  ends_at: 7.days.from_now,
  active: true
)

Coupon.create!(
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

Coupon.create!(
  code: "LIMITED",
  discount_type: "fixed_amount",
  discount_value: 10_000,
  min_order_amount: 50_000,
  usage_limit: 1,
  used_count: 1,
  starts_at: 1.day.ago,
  ends_at: 7.days.from_now,
  active: true
)

Wallet.create!(
  user_id: user.id,
  balance: 1_000_000
)

puts "Seed done!"
puts "Books: #{Book.count}"
puts "Orders: #{Order.count}"
puts "Coupons: #{Coupon.count}"
puts "Wallets: #{Wallet.count}"
