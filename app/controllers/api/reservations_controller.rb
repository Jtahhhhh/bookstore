class Api::ReservationsController < Api::BaseController
    def create
        result = Reservations::CreateService.new(reservation_params, reservation_items_params, flash_sale_id).call
        render json: result.except(:status), status: result[:status]
    end

    private
    def reservation_params
        params.permit(:idempotency_key)
    end

    def reservation_items_params
        params.require(:items)
    end

    def flash_sale_id
        params[:flash_sale_id]
    end
end
