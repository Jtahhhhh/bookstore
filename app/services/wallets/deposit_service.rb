module Wallets
    class DepositService
        def initialize(deposit_params)
            @amount = deposit_params[:amount]
            @transaction_key = deposit_params[:transaction_key]
            @meta_data = deposit_params[:meta_data]
            @user_id = deposit_params[:user_id]
        end

        def call
            wallet = Wallet.find_by(user_id: @user_id)
            ActiveRecord::Base.transaction do
                if wallet.present?
                    wallet.with_Lock do
                        wallet.add_funds(@amount.to_d, @transaction_key, @meta_data)
                    end
                    render json: { message: "Funds deposited successfully", balance: wallet.balance }, status: :ok
                else
                    raise ActiveRecord::RecordNotFound, "Wallet not found"
                end
            end
            rescue ActiveRecord::RecordNotUnique => e
                render json: { error: "Event already processed" }, status: :ok
            rescue ActiveRecord::RecordInvalid => e
                render json: { error: e.message }, status: :unprocessable_entity
            end
            end
        end
    end
end