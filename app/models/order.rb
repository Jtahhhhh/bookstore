class Order < ApplicationRecord
    before_save :calculate_total_price

    has_many :order_items, dependent: :destroy
    has_many :books, through: :order_items

    validates :customer_name, presence: true
    validates :customer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    accepts_nested_attributes_for :order_items, allow_destroy: true


    scope :with_items, -> { includes(:order_items, :books) }

     private

    def calculate_total_price
        self.total_price = order_items.sum(&:subtotal)
    end
end
