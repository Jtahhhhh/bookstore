class FlashSale < ApplicationRecord
    has_many :flash_sale_items, dependent: :destroy
    has_many :books, through: :flash_sale_items

    validates :name, presence: true
    validates :start_time, presence: true
    validates :end_time, presence: true
    validates :status, presence: true, inclusion: { in: %w[active expired] }

    scope :active, -> { where(status: "active").where("start_time <= ? AND end_time >= ?", Time.current, Time.current) }

    enum :status, {
        active: "active",
        expired: "expired"
    }
end
