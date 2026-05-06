class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false, default: 0.0
      t.string :status, null: false, default: "pending"
      t.string :provider, null: false
      t.string :provider_transaction_id, null: false
      t.datetime :paid_at, null: true
      t.string :failed_reason

      t.index :provider_transaction_id, unique: true
      t.timestamps
    end
  end
end
