class Coupon < ApplicationRecord
    before_create :starts_at_in_fasts, :ends_at_future, :ends_at_after_starts_at
    has_many :coupon_redemptions, dependent: :destroy
    
    validates :code, presence: true, uniqueness: true
    validates :discount_type, presence: true, inclusion: { in: %w[percentage fixed_amount] }
    validates :discount_value, numericality: { greater_than: 0 }
    validates :starts_at, :ends_at, presence: true

    scope :active, -> { where(active: true) }

    enum :discount_type, { percentage: "percentage", fixed_amount:"fixed_amount" }
    
    private 
    def ends_at_future
        return if ends_at.blank?
        if ends_at <= Time.current
            errors.add(:ends_at, "must be in the future")
        end
    end

    def starts_at_in_fasts
        return if starts_at.blank?
        if starts_at >= Time.current
            errors.add(:starts_at, "must be in the future")
        end
    end

    def ends_at_after_starts_at
        return if ends_at.blank? || starts_at.blank?
        if ends_at <= starts_at
            errors.add(:ends_at, "must be after the start date")
        end
    end
end
