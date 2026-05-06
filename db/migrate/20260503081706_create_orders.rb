class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :customer_name
      t.string :customer_email
      t.string :status, default: "pending", null: false
      t.decimal :total_price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
