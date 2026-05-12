module Wallets
  class PayService
    include ServiceResponse
    def initialize(deposit_params)
      @order_id = deposit_params[:id]
      @transaction_key = deposit_params[:idempotency_key]
      @user_id = deposit_params[:user_id]
    end

    def call
      return error("Transaction key is required") if @transaction_key.blank?

      wallet = find_wallet
      return not_found("Wallet not found") unless wallet
      order = Order.find_by(id: @order_id)
      return not_found("Order not found") unless order
      return error("Not enough money to pay.") if wallet.balance < order.total_price

      ActiveRecord::Base.transaction do
        wallet.with_lock do
          wallet.deduct_funds(order.total_price, @transaction_key, "")
        end
        order.status = "paid"
        order.save!
        process_payment_succeeded(order)
      end

      success("Payment completed successfully", {
        "order":{
          "id": order.id,
          "status": order.status
        },
        "payment": {
          "status": "paid",
          "provider": "wallet"
        }, "wallet": {
          "user_id": wallet.user_id,
          "balance": wallet.balance
        }
      })
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => e
      existing = LedgerEntry.find_by(transaction_key: @transaction_key)
      return success("Transaction already processed", balance: wallet.reload.balance) if existing

      error(e.message)
    end

    private 
    def find_wallet
      Wallet.find_by(user_id: @user_id)
    end

    def process_payment_succeeded(order)
        payment = Payment.find_or_initialize_by(provider_transaction_id: "pay_order_#{@order_id}" )
        payment.provider = 'wallet'
        payment.status = "paid"
        payment.amount = order.total_price
        payment.order_id = order.id
        payment.paid_at = Time.current
        payment.save!
    end
  end
end
