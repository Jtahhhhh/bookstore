class ReservationItem < ApplicationRecord
    belongs_to :reservation
    belongs_to :flash_sale_item

    validates :quantity, numericality: { greater_than: 0 }
    validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
    validates :subtotal, numericality: { greater_than_or_equal_to: 0 }
end
