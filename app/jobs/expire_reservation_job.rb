class ExpireReservationJob < ApplicationJob
  queue_as :default

  def perform(reservation_id)
    reservation = Reservation.includes(:reservation_items).find_by(id: reservation_id)
    return unless reservation
    return unless reservation.status == "pending"
    return if reservation.expires_at > Time.current

    ActiveRecord::Base.transaction do
      reservation.lock!

      return unless reservation.status == "pending"

      reservation.reservation_items.each do |item|
        item.flash_sale_item.with_lock do
          item.flash_sale_item.stock += item.quantity
          item.flash_sale_item.save!
        end
      end

      reservation.update!(status: "expired")
    end
  end
end
