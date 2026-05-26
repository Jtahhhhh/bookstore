require "test_helper"

class Api::WalletsControllerTest < ActionDispatch::IntegrationTest

  test "should deposit funds successfully" do
    user = sign_in_test_user
    wallet = Wallet.create!(user_id: user.id, balance: 100)
    post deposit_api_wallet_path(wallet), params: { amount: 50, transaction_key: "deposit-1" }
    assert_response :success
    wallet.reload
    assert_equal 150, wallet.balance.to_f
  end

  test "should withdraw funds successfully" do
    user = sign_in_test_user
    wallet = Wallet.create!(user_id: user.id, balance: 100)
    post withdraw_api_wallet_path(wallet), params: { amount: 30, transaction_key: "withdraw-1" }
    assert_response :success
    wallet.reload
    assert_equal 70, wallet.balance.to_f
  end

  test "should transfer funds successfully" do
    user = sign_in_test_user
    destination_user = User.create!(email: "destination@example.com", password: "password", password_confirmation: "password")
    source_wallet = Wallet.create!(user_id: user.id, balance: 100)
    destination_wallet = Wallet.create!(user_id: destination_user.id, balance: 50)
    post transfer_api_wallet_path(source_wallet), params: { amount: 30, transaction_key: "transfer-1", destination_user_id: destination_wallet.user_id }
    assert_response :success
    source_wallet.reload
    destination_wallet.reload
    assert_equal 70, source_wallet.balance.to_f
    assert_equal 80, destination_wallet.balance.to_f
  end

  test "should return error for insufficient funds" do
    user = sign_in_test_user
    wallet = Wallet.create!(user_id: user.id, balance: 20)
    post withdraw_api_wallet_path(wallet), params: { amount: 30, transaction_key: "withdraw-insufficient" }
    assert_response :unprocessable_entity
    wallet.reload
    assert_equal 20, wallet.balance.to_f
  end

  test "should return error for non-existent wallet" do
    sign_in_test_user
    post deposit_api_wallet_path(id: "non_existent_user"), params: { amount: 50, transaction_key: "missing-wallet" }
    assert_response :not_found
  end

  test "should return error for duplicate transaction" do
    user = sign_in_test_user
    wallet = Wallet.create!(user_id: user.id, balance: 100)
    post deposit_api_wallet_path(wallet), params: { amount: 50, transaction_key: "duplicate-deposit" }
    assert_response :success

    post deposit_api_wallet_path(wallet), params: { amount: 50, transaction_key: "duplicate-deposit" }
    assert_response :ok
    wallet.reload
    assert_equal 150, wallet.balance.to_f
  end

  test "should transfer funds failed due to insufficient funds" do
    user = sign_in_test_user
    destination_user = User.create!(email: "destination-2@example.com", password: "password", password_confirmation: "password")
    source_wallet = Wallet.create!(user_id: user.id, balance: 100)
    destination_wallet = Wallet.create!(user_id: destination_user.id, balance: 50)
    post transfer_api_wallet_path(source_wallet), params: { amount: 200, transaction_key: "transfer-insufficient", destination_user_id: destination_wallet.user_id }
    assert_response :unprocessable_entity
    source_wallet.reload
    destination_wallet.reload
    assert_equal 100, source_wallet.balance.to_f
    assert_equal 50, destination_wallet.balance.to_f
  end
end
