class Api::WalletsController < Api::BaseController
    def deposit_funds
        result = Wallets::DepositService.new(wallet_params.merge(wallet_id: params[:id])).call
        render json: result.except(:status), status: result[:status]
    end

    def withdraw_funds
        result = Wallets::WithdrawService.new(wallet_params.merge(wallet_id: params[:id])).call
        render json: result.except(:status), status: result[:status]
    end

    def transfer_funds
        result = Wallets::TransferService.new(transfer_params.merge(wallet_id: params[:id])).call
        render json: result.except(:status), status: result[:status]
    end

    private 
    def wallet_params
        params.permit(:amount, :transaction_key, meta_data: {})
    end

    def transfer_params
        params.permit(:amount, :transaction_key, :destination_user_id, meta_data: {})
    end
end
