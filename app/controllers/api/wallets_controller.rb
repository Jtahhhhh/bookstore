class Api::WalletsController < Api::BaseController
    def deposit_funds
        result = Wallets::DepositService.new(wallet_params).call
        render json: result.except(:status), status: result[:status]
    end

    def withdraw_funds
        result = Wallets::WithdrawService.new(wallet_params).call
        render json: result.except(:status), status: result[:status]
    end

    def transfer_funds
        result = Wallets::TransferService.new(transfer_params).call
        render json: result.except(:status), status: result[:status]
    end

    private 
    def wallet_params
        params.permit(:amount, :transaction_key, meta_data: {}).merge(user_id: current_user.id)
    end

    def transfer_params
        params.permit(:amount, :transaction_key, :destination_user_id, meta_data: {}).merge(user_id: current_user.id)
    end
end
