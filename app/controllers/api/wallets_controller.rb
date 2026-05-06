class Api::WalletsController < Api::BaseController
    def deposit_funds
         Wallets::DepositService.new(wallet_params).call
    end

    def withdraw_funds
        Wallets::WithdrawService.new(wallet_params).call
    end

    def transfer_funds
        Wallets::TransferService.new(transfer_params).call
    end

    private 
    def wallet_params
        params.permit(:amount, :transaction_key)
    end

    def transfer_params
        params.permit(:amount, :transaction_key, :destination_user_id)
    end
end
