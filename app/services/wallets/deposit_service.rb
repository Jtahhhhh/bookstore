module Wallets
  class DepositService
    def initialize(deposit_params)
      @amount = deposit_params[:amount].to_d
      @transaction_key = deposit_params[:transaction_key]
      @meta_data = deposit_params[:meta_data] || {}
      @wallet_id = deposit_params[:wallet_id]
    end

    def call
      return error("Transaction key is required") if @transaction_key.blank?
      return error("Amount must be greater than 0") unless @amount.positive?

      wallet = find_wallet
      return not_found("Wallet not found") unless wallet

      ActiveRecord::Base.transaction do
        wallet.with_lock do
          wallet.add_funds(@amount, @transaction_key, @meta_data)
        end
      end

      success("Funds deposited successfully", balance: wallet.reload.balance)
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => e
      existing = LedgerEntry.find_by(transaction_key: @transaction_key)
      return success("Transaction already processed", balance: wallet.reload.balance) if existing

      error(e.message)
    end

    private

    def success(message, data = {})
      { status: :ok, message: message }.merge(data)
    end

    def error(message)
      { status: :unprocessable_entity, error: message }
    end

    def not_found(message)
      { status: :not_found, error: message }
    end

    def find_wallet
      Wallet.find_by(id: @wallet_id) || Wallet.find_by(user_id: @wallet_id)
    end
  end
end
