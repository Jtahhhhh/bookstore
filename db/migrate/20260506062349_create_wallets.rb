class CreateWallets < ActiveRecord::Migration[8.1]
  def change
    create_table :wallets do |t|
      t.string :user_id, null: false
      t.decimal :balance, precision: 10, scale: 2, null: false, default: 0

      t.index :user_id, unique: true
      t.timestamps
    end
  end
end
