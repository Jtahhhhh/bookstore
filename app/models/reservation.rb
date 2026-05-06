class Reservation < ApplicationRecord
    has_many :reservation_items, dependent: :destroy
    has_many :flash_sale_items, through: :reservation_items
    belongs_to :flash_sale

end
