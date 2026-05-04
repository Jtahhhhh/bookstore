module Reservations
    class CreateService
        include ServiceResponse
        def initialize(reservation_params,reservation_items_params, flash_sale_id)
            @flash_sale = FlashSale.find_by(id: flash_sale_id)
            @reservation_params = reservation_params
            @reservation_items_params = reservation_items_params
        end

        def call
            return not_found("Flash sale not found") unless @flash_sale
            return error("Flash sale is not active") unless @flash_sale.active?
            return error("Invalid reservation parameters.") unless @reservation_params
            return error("Reservation must contain at least one item.") if @reservation_items_params.blank?
            return error("Idempotency key is required.") if @reservation_params[:idempotency_key].blank?
            existing = Reservation.find_by(idempotency_key:  @reservation_params[:idempotency_key])
            return success(order: existing.as_json(include: { reservation_items: { include: :flash_sale_item } }), status: :ok) if existing
                reservation = Reservation.new(
                    flash_sale: @flash_sale,
                    idempotency_key: @reservation_params[:idempotency_key],
                    expires_at: Time.current + 15.minutes,
                    status: "pending"
                )
                reservation.reservation_items = @reservation_items_params.map do |item|
                    flash_sale_item = FlashSaleItem.find_by(book_id: item[:book_id], flash_sale: @flash_sale)
                    return not_found("Flash sale item not found: #{item[:flash_sale_item_id]}") unless flash_sale_item

                    ReservationItem.new(
                        flash_sale_item: flash_sale_item,
                        quantity: item[:quantity],
                        unit_price: flash_sale_item.sale_price,
                        subtotal: flash_sale_item.sale_price * item[:quantity].to_i
                    )
                end

            return error("Reservation must contain at least one item.") if reservation.reservation_items.empty?

            ActiveRecord::Base.transaction do
                if reservation.save!
                    # gọi background job để tự động hủy reservation sau 15 phút nếu không được thanh toán
                    ExpireReservationJob.set(wait_until: reservation.expires_at).perform_later(reservation.id)
                    reservation.reservation_items.each do |item|
                        item.flash_sale_item.with_lock do
                            if item.flash_sale_item.stock < item.quantity
                                return error("Insufficient stock for book #{item.flash_sale_item.book_id}")
                            end

                            item.flash_sale_item.stock -= item.quantity
                            item.flash_sale_item.save!
                        end
                    end
                    return success(order: reservation.as_json(include: { reservation_items: { include: :flash_sale_item } }), status: :created)
                end
            rescue ActiveRecord::RecordNotUnique
                existing = Reservation.find_by(idempotency_key:  @reservation_params[:idempotency_key])
                return success(order: existing.as_json(include: { reservation_items: { include: :flash_sale_item } }), status: :ok) if existing      
            rescue ActiveRecord::RecordInvalid => e
                return error("Failed to create reservation: #{e.message}")
            end
        end
    end
end