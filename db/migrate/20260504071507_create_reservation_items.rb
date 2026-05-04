class CreateReservationItems < ActiveRecord::Migration[8.1]
  def change
    create_table :reservation_items do |t|
      t.references :reservation, null: false, foreign_key: true
      t.references :flash_sale_item, null: false, foreign_key: true
      t.integer :quantity, default: 1, null: false
      t.decimal :unit_price, precision: 8, scale: 2, null: false
      t.decimal :subtotal, precision: 10, scale: 2, null: false

      t.index [:reservation_id, :flash_sale_item_id], unique: true

      t.timestamps
    end
  end
end
