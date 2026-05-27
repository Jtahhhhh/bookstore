class Order < ApplicationRecord

    has_many :order_items, dependent: :destroy
    has_many :books, through: :order_items

    validates :customer_name, presence: true
    validates :customer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    accepts_nested_attributes_for :order_items, allow_destroy: true


    scope :with_items, -> { includes(:order_items, :books) }
end
