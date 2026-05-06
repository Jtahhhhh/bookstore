class CreateLedgerEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :ledger_entries do |t|
      t.references :wallet, null: false, foreign_key: true
      t.string :transaction_key, null: false
      t.string :entry_type, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :balance_after, precision: 10, scale: 2, null: false
      t.jsonb :meta_data, null: false, default: {}

      t.index :transaction_key, unique: true
      t.timestamps
    end
  end
end
