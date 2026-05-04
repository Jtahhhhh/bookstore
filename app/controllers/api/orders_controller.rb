class Api::OrdersController < Api::BaseController

    def create
        result = Orders::CreateService.new(order_params, customer_params).call

        render json: result.except(:status), status: result[:status]
        rescue => e
        render json: { error: e.message }, status: :internal_server_error
    end


    private
    def customer_params
        params.require(:order).permit(:customer_name, :customer_email)
    end

    def order_params
        params.require(:order).permit(
            items: [
                :book_id,
                :quantity,
            ]
        )
    end
end
