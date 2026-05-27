class AddIdempotencyKeyForOrder < ActiveRecord::Migration[8.1]
  def change
      add_column :orders, :idempotency_key, :string
      add_index :orders, :idempotency_key, unique: true
  end
end
