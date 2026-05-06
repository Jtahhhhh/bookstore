class LedgerEntry < ApplicationRecord
    belongs_to :wallet
    
    validates :transaction_key, presence: true, uniqueness: true
    validates :entry_type, presence: true, inclusion: { in: %w[credit debit] }
    validates :amount, numericality: { greater_than: 0 }
    validates :balance_after, numericality: { greater_than_or_equal_to: 0 }
end
