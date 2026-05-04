class CreateReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :reservations do |t|
      t.references :flash_sale, null: false, foreign_key: true
      t.string :idempotency_key, null: false
      t.string :status, null: false, default: "pending"
      t.datetime :expires_at, null: false

      t.index :idempotency_key, unique: true

      t.timestamps
    end
  end
end
