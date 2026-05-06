class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.text :description
      t.decimal :price, precision: 8, scale: 2, default: 0.0, null: false
      t.integer :stock, default: 0, null: false
      t.boolean :published, default: true
      t.references :author, null: false, foreign_key: true

      t.timestamps
    end
  end
end
