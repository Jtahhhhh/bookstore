class CreateCoupons < ActiveRecord::Migration[8.1]
  def change
    create_table :coupons do |t|
      t.string :code, null: false
      t.string :discount_type, null: false
      t.decimal :discount_value, precision: 10, scale: 2, null: false
      t.decimal :min_order_amount, precision: 10, scale: 2
      t.decimal :max_discount_amount, precision: 10, scale: 2
      t.integer :usage_limit, default: 1
      t.integer :used_count, default: 0
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.boolean :active, default: true, null: false

      t.index :code, unique: true

      t.timestamps
    end
  end
end
