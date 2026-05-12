class Api::OrdersController < Api::BaseController

    def create
        result = Orders::CreateService.new(order_params, customer_params,coupon_params).call
        render json: result.except(:status), status: result[:status]
        rescue => e
        render json: { error: e.message }, status: :internal_server_error
    end

    def pay_with_wallet
        result = Wallets::PayService.new(pay_params).call
        render json: result.except(:status), status: result[:status]
        rescue => e
        render json: { error: e.message }, status: :internal_server_error
    end


    private
    def pay_params
        params.permit(
            :user_id,
            :idempotency_key,
            :id 
        )
    end

    def customer_params
        params.require(:order).permit(:customer_name, :customer_email)
    end

    def coupon_params 
        params.require(:order).permit(
            :coupon_code,
            :user_id,
            :idempotency_key
            )
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
