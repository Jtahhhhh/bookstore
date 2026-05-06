module Wallets
  class TransferService
    def initialize(transfer_params)
      @amount = transfer_params[:amount].to_d
      @transaction_key = transfer_params[:transaction_key]
      @wallet_id = transfer_params[:wallet_id]
      @meta_data = transfer_params[:meta_data] || {}
      @destination_user_id = transfer_params[:destination_user_id]
    end

    def call
      return error("Transaction key is required") if @transaction_key.blank?
      return error("Amount must be greater than 0") unless @amount.positive?

      source_wallet = find_wallet(@wallet_id)
      destination_wallet = Wallet.find_by(user_id: @destination_user_id)
      return not_found("Source or destination wallet not found") unless source_wallet && destination_wallet

      debit_key = "#{@transaction_key}:debit"
      credit_key = "#{@transaction_key}:credit"

      if LedgerEntry.exists?(transaction_key: debit_key) || LedgerEntry.exists?(transaction_key: credit_key)
        return success(
          "Transaction already processed",
          source_balance: source_wallet.balance,
          destination_balance: destination_wallet.balance
        )
      end

      ActiveRecord::Base.transaction do
        first_wallet, second_wallet = [source_wallet, destination_wallet].sort_by(&:id)

        first_wallet.with_lock do
          second_wallet.with_lock do
            source_wallet.reload
            destination_wallet.reload

            return error("Insufficient funds") if source_wallet.balance < @amount

            source_wallet.deduct_funds(
              @amount,
              debit_key,
              @meta_data.merge(destination_user_id: @destination_user_id)
            )
            destination_wallet.add_funds(
              @amount,
              credit_key,
              @meta_data.merge(source_wallet_id: source_wallet.id)
            )
          end
        end
      end

      success(
        "Funds transferred successfully",
        source_balance: source_wallet.reload.balance,
        destination_balance: destination_wallet.reload.balance
      )
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => e
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

    def find_wallet(identifier)
      Wallet.find_by(id: identifier) || Wallet.find_by(user_id: identifier)
    end
  end
end
