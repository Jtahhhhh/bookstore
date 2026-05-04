class CreateFlashSaleItems < ActiveRecord::Migration[8.1]
  def change
    create_table :flash_sale_items do |t|
      t.references :flash_sale, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.decimal :sale_price, precision: 8, scale: 2, null: false
      t.integer :stock, default: 0, null: false

      t.index [:flash_sale_id, :book_id], unique: true

      t.timestamps
    end
  end
end
