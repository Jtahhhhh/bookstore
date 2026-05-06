module Wallets 
    class TransferService
        def initialize(transfer_params)
            @amount = transfer_params[:amount]
            @transaction_key = transfer_params[:transaction_key]
            @user_id = transfer_params[:user_id]
            @meta_data = transfer_params[:meta_data]
            @destination_user_id = transfer_params[:destination_user_id]
        end

        def call
            source_wallet = Wallet.find_by(user_id: @user_id)
            destination_wallet = Wallet.find_by(user_id: @destination_user_id)

            ActiveRecord::Base.transaction do
                if source_wallet.nil? || destination_wallet.nil?
                    raise ActiveRecord::RecordNotFound, "Source or destination wallet not found"
                end
                raise ActiveRecord::RecordInvalid, "Insufficient funds" if source_wallet.balance < @amount.to_d
                source_wallet.with_Lock do
                    source_wallet.deduct_funds(@amount.to_d, @transaction_key, {@meta_data})
                end
                destination_wallet.with_Lock do
                    destination_wallet.add_funds(@amount.to_d, @transaction_key, { @meta_data })
                end
                render json: { message: "Funds transferred successfully", source_balance: source_wallet.balance, destination_balance: destination_wallet.balance }, status: :ok
            end
            rescue ActiveRecord::RecordNotUnique => e
                render json: { error: "Event already processed" }, status: :ok
            rescue ActiveRecord::RecordInvalid => e
                render json: { error: e.message }, status: :unprocessable_entity
        end
    end
end