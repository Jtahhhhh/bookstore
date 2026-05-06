module Wallets 
    class WithdrawService
        def initialize(withdraw_params)
            @amount = withdraw_params[:amount]
            @meta_data = withdraw_params[:meta_data]
            @transaction_key = withdraw_params[:transaction_key]
            @user_id = withdraw_params[:user_id]
        end

        def call
            wallet = Wallet.find_by(user_id: @user_id)
            ActiveRecord::Base.transaction do
                if wallet.present?
                    wallet.with_Lock do
                        wallet.deduct_funds(@amount.to_d, @transaction_key, @meta_data)
                    end
                    render json: { message: "Funds withdrawn successfully", balance: wallet.balance }, status: :ok
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