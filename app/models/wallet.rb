class Wallet < ApplicationRecord
    belongs_to :user
    has_many :ledger_entries, dependent: :destroy
    
    validates :user_id, presence: true, uniqueness: true
    validates :balance, numericality: { greater_than_or_equal_to: 0 }
    
    def add_funds(amount, transaction_key, meta_data = {})
        raise ActiveRecord::RecordInvalid, self unless amount.to_d.positive?

        self.balance += amount
        save!
    
        ledger_entries.create!(
            transaction_key: transaction_key,
            entry_type: 'credit',
            amount: amount,
            balance_after: balance,
            meta_data: meta_data
        )
    end
    
    def deduct_funds(amount, transaction_key, meta_data = {})
        raise ActiveRecord::RecordInvalid, self unless amount.to_d.positive?
        errors.add(:balance, "insufficient funds") if balance < amount
        raise ActiveRecord::RecordInvalid, self if errors[:balance].any?

        self.balance -= amount
        save!
        ledger_entries.create!(
            transaction_key: transaction_key,
            entry_type: 'debit',
            amount: amount,
            balance_after: balance,
            meta_data: meta_data
        )
    end
end
