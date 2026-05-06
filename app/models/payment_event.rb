class PaymentEvent < ApplicationRecord
    validates :event_id, presence: true, uniqueness: true
    validates :event_type, presence: true
    validates :provider, presence: true
end
