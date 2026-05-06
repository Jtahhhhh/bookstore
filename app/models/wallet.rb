class Wallet < ApplicationRecord
    has_many :ledger_entries, dependent: :destroy
    
    validates :user_id, presence: true, uniqueness: true
    validates :balance, numericality: { greater_than_or_equal_to: 0 }
    
    def add_funds(amount, transaction_key, meta_data = {})
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
