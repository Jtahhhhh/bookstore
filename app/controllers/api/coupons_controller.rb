class Api::CouponsController < Api::BaseController
  def preview
    result = Coupons::PreviewService.new(coupon_params.merge(user_id: current_user.id)).call
    render json: result.except(:status), status: result[:status]
  end

  private

  def coupon_params
    params.permit(
      :coupon_code,
      order: [
        :order_id,
        items: [
          :book_id,
          :quantity
        ]
      ]
    )
  end
end
