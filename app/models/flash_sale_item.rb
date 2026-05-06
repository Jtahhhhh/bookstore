class FlashSaleItem < ApplicationRecord
    belongs_to :flash_sale
    belongs_to :book

    validates :sale_price, numericality: { greater_than_or_equal_to: 0 }
    validates :stock, numericality: { greater_than_or_equal_to: 0 }
end
