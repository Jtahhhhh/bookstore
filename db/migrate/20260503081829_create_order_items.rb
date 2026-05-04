class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :quantity, default: 1, null: false
      t.decimal :unit_price, precision: 8, scale: 2, null: false
      t.decimal :subtotal, precision: 10, scale: 2, null: false

      t.index [:order_id, :book_id], unique: true
      t.timestamps
    end
  end
end
