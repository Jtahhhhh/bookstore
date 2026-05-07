class CouponRedemption < ApplicationRecord
    belongs_to :coupon
    
    validates :user_id, presence: true
    validates :coupon_id, presence: true
    validates :order_id, presence: true
    validates :idempotency_key, presence: true, uniqueness: true
    validates :discount_amount, numericality: { greater_than_or_equal_to: 0 }
    validates :final_amount, numericality: { greater_than_or_equal_to: 0 }

end
