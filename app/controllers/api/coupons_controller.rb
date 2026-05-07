class Api::CouponsController < Api::BaseController
  def preview
    result = Coupons::PreviewService.new(coupon_params).call
    render json: result.except(:status), status: result[:status]
  end

  def apply
    result = Coupons::ApplyService.new(coupon_params).call
    render json: result.except(:status), status: result[:status]
  end

  private

  def coupon_params
    params.permit(
      :idempotency_key,
      :coupon_code,
      :user_id,
      order: [
        :order_id,
        items: [
          :book_id,
          :title,
          :unit_price,
          :quantity
        ]
      ]
    )
  end
end
