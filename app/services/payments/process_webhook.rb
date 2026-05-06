module Payments
    class ProcessWebhook
        class WebhookError < StandardError; end
        def initialize(params)
            @event_id = params[:event_id]
            @event_type = params[:event_type]
            @provider = params[:provider]
            @data = params[:data]
        end

        def call
            ActiveRecord::Base.transaction do
                
                case @event_type
                when "payment.succeeded"
                    process_payment_succeeded
                when "payment.refunded"
                    process_payment_refunded
                when "payment.failed"
                    process_payment_failed
                else
                    return error("Unknown event type: #{@event_type}")
                end
                insert_payment_event
                ok("Webhook processed successfully")
            rescue ActiveRecord::RecordInvalid, WebhookError => e
                error(e.message)
            rescue ActiveRecord::RecordInvalid => e
                error(e.message)
            rescue ActiveRecord::RecordNotUnique
                ok("Event already processed")
            end
        end

        private
        def process_payment_succeeded
            payment = Payment.find_or_initialize_by(provider_transaction_id: @data[:provider_payment_id])
            payment.provider = @provider
            payment.status = "paid"
            payment.amount = @data[:amount]
            payment.order_id = @data[:order_id]
            payment.paid_at = Time.current
            payment.save!
        end

        def process_payment_refunded
            payment = Payment.find_by(provider_transaction_id: @data[:provider_payment_id])
            raise WebhookError, "Payment not found" unless payment unless payment
            raise WebhookError, "Payment not paid yet" unless payment.paid?
            payment.provider = @provider
            payment.status = "refunded"
            payment.save!
        end

        def process_payment_failed
            payment = Payment.find_by(provider_transaction_id: @data[:provider_payment_id])
            raise WebhookError, "Payment not found" unless payment unless payment
            payment.provider = @provider
            payment.status = "failed"
            payment.failed_reason = @data[:failure_reason]
            payment.save!
        end
        
        def insert_payment_event
            PaymentEvent.create!(
                event_id: @event_id,
                event_type: @event_type,
                provider: @provider,
                payload: @data,
                processed_at: Time.current
            )
        end

        def ok(message)
            {
                status: :ok,
                message: message,
                data: {
                payment: {
                    event_id: @event_id,
                    event_type: @event_type,
                    provider: @provider
                },
                event: {
                    id: @event_id
                }
                }
            }
        end
        def error(message)
            { status: :unprocessable_entity, error: message }
        end
    end
end
