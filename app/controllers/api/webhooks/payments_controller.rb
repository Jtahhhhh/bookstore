class Api::Webhooks::PaymentsController < Api::BaseController
    skip_before_action :authenticate_user!
    before_action :authenticate_webhook!
    def create
        result = Payments::ProcessWebhook.new(payment_params).call

        render json: result.except(:status), status: result[:status], message: result[:message]
    end

    private
    def authenticate_webhook!
        token = request.headers["X-FakePay-Signature"]
        secret = ENV["FAKEPAY_WEBHOOK_SECRET"]
        unless secret.present? && token.bytesize == secret.bytesize && token && ActiveSupport::SecurityUtils.secure_compare(token, secret)
            render json: { error: "Unauthorized" }, status: :unauthorized
        end
    end
    def payment_params
        params.permit(:event_id, :event_type, :provider, data: {})
    end
end
