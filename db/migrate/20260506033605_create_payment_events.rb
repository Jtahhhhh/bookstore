class CreatePaymentEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_events do |t|
      t.string :event_id, null: false
      t.string :event_type, null: false
      t.string :provider, null: false
      t.jsonb :payload, null: false, default: {}
      t.datetime :processed_at, null: true

      t.index :event_id, unique: true
      t.timestamps
    end
  end
end
