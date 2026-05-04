class OrderItem < ApplicationRecord
    before_validation :set_prices
    belongs_to :order
    belongs_to :book

    validates :quantity, numericality: { greater_than: 0 }


    private

    def set_prices
        self.unit_price ||= book&.price || 0
        self.subtotal = quantity.to_i * unit_price.to_d
    end
end
