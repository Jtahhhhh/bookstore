class CreateFlashSales < ActiveRecord::Migration[8.1]
  def change
    create_table :flash_sales do |t|
      t.string :name, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.string :status, null: false, default: "active"

      t.timestamps
    end
  end
end
