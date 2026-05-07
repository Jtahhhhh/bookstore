class CreateCouponRedemptions < ActiveRecord::Migration[8.1]
  def change
    create_table :coupon_redemptions do |t|

      t.references :coupon, null: false, foreign_key: true
      t.string :user_id, null: false
      t.string :order_id, null: false
      t.string :idempotency_key, null: false
      t.decimal :discount_amount, precision: 10, scale: 2, null: false
      t.decimal :original_amount, precision: 10, scale: 2, null: false
      t.decimal :final_amount, precision: 10, scale: 2, null: false

      t.index [:coupon_id, :user_id, :order_id], unique: true
      t.index :idempotency_key, unique: true

      t.timestamps
    end
  end
end
