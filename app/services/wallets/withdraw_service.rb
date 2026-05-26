module Wallets
  class WithdrawService
    def initialize(withdraw_params)
      @amount = withdraw_params[:amount].to_d
      @transaction_key = withdraw_params[:transaction_key]
      @meta_data = withdraw_params[:meta_data] || {}
      @user_id = withdraw_params[:user_id]
      @wallet_id = withdraw_params[:wallet_id]
    end

    def call
      return error("Transaction key is required") if @transaction_key.blank?
      return error("Amount must be greater than 0") unless @amount.positive?

      wallet = find_wallet
      return not_found("Wallet not found") unless wallet

      ActiveRecord::Base.transaction do
        wallet.with_lock do
          return error("Insufficient funds") if wallet.balance < @amount

          wallet.deduct_funds(@amount, @transaction_key, @meta_data)
        end
      end

      success("Funds withdrawn successfully", balance: wallet.reload.balance)
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
      return Wallet.find_by(user_id: @user_id) if @user_id.present?

      Wallet.find_by(id: @wallet_id) || Wallet.find_by(user_id: @wallet_id)
    end
  end
end
