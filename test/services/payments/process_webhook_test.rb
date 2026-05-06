require "test_helper"

class Payments::ProcessWebhookTest < ActiveSupport::TestCase
    test "succeeded event creates paid payment" do
        params = {
            event_id: "evt_123",
            event_type: "payment.succeeded",
            provider: "FakePay",
            data: {
                provider_payment_id: "pay_123",
                amount: 1000,
                order_id: 1
            }
        }
        result = Payments::ProcessWebhook.new(params).call
        
        assert result[:success]
        
        payment = Payment.find_by(provider_transaction_id: "pay_123")

        assert payment
        assert_equal "paid", payment.status
        assert_equal 1000, payment.amount
        assert_equal 1, payment.order_id
    end

   test "failed event marks payment failed" do 
        params = {
            event_id: "evt_456",
            event_type: "payment.failed",
            provider: "FakePay",
            data: {
                provider_payment_id: payment.provider_transaction_id,
                failure_reason: "Card declined"
            }
        }
        result = Payments::ProcessWebhook.new(params).call
        assert result[:success]
        payment.reload
        assert_equal "failed", payment.status
        assert_equal "Card declined", payment.failed_reason
        assert_not_nil payment.failed_at
    end

    test "refunded event marks payment refunded" do
        payment = Payment.create!(
            order_id: 1,
            amount: 1000,
            status: "paid",
            provider: "FakePay",
            paid_at: 1.hour.ago
        )
        params = {
            event_id: "evt_789",
            event_type: "payment.refunded",
            provider: "FakePay",
            data: {
                provider_payment_id: payment.provider_transaction_id
            }
        }
        result = Payments::ProcessWebhook.new(params).call
        assert result[:success]
        payment.reload
        assert_equal "refunded", payment.status
    end
end