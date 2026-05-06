class Payment < ApplicationRecord
    belongs_to :order

    validates :status, presence: true, inclusion: { in: %w[pending paid refunded failed] }
    validates :amount  , numericality: { greater_than_or_equal_to: 0 }

    enum :status, { pending: "pending", paid: "paid", refunded: "refunded", failed: "failed" }
end
