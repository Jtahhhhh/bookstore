class DiscountAmountToOrder < ActiveRecord::Migration[8.1]
  def change
      add_column :orders, :discount_amount, :decimal, precision: 10, scale: 2, null: false, default: 0
      add_column :orders, :original_amount, :decimal, precision: 10, scale: 2, null: false, default: 0
  end
end
