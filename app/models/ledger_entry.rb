class LedgerEntry < ApplicationRecord
    belongs_to :wallet
    
    validates :transaction_key, presence: true, uniqueness: true
end
