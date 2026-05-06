require "test_helper"

class Api::WalletsControllerTest < ActionDispatch::IntegrationTest

  test "should deposit funds successfully" do
    wallet = Wallet.create!(user_id: "user1", balance: 100)
    post deposit_api_wallet_path(wallet), params: { amount: 50 }
    assert_response :success
    wallet.reload
    assert_equal 150, wallet.balance.to_f
  end

  test "should withdraw funds successfully" do
    wallet = Wallet.create!(user_id: "user2", balance: 100)
    post withdraw_api_wallet_path(wallet), params: { amount: 30 }
    assert_response :success
    wallet.reload
    assert_equal 70, wallet.balance.to_f
  end

  test "should transfer funds successfully" do
    source_wallet = Wallet.create!(user_id: "user1", balance: 100)
    destination_wallet = Wallet.create!(user_id: "user2", balance: 50)
    post transfer_api_wallet_path(source_wallet), params: { amount: 30, destination_user_id: destination_wallet.user_id }
    assert_response :success
    source_wallet.reload
    destination_wallet.reload
    assert_equal 70, source_wallet.balance.to_f
    assert_equal 80, destination_wallet.balance.to_f
  end

  test "should return error for insufficient funds" do
    wallet = Wallet.create!(user_id: "user3", balance: 20)
    post withdraw_api_wallet_path(wallet), params: { amount: 30 }
    assert_response :unprocessable_entity
    wallet.reload
    assert_equal 20, wallet.balance.to_f
  end

  test "should return error for non-existent wallet" do
    post deposit_api_wallet_path(id: "non_existent_user"), params: { amount: 50 }
    assert_response :not_found
  end

  test "should return error for duplicate transaction" do
    wallet = Wallet.create!(user_id: "user4", balance: 100)
    post deposit_api_wallet_path(wallet), params: { amount: 50 }
    assert_response :success

    # Simulate duplicate transaction by using the same transaction key
    post deposit_api_wallet_path(wallet), params: { amount: 50 }
    assert_response :ok
    wallet.reload
    assert_equal 150, wallet.balance.to_f
  end

  test "should transfer funds failed due to insufficient funds" do
    source_wallet = Wallet.create!(user_id: "user1", balance: 100)
    destination_wallet = Wallet.create!(user_id: "user2", balance: 50)
    post transfer_api_wallet_path(source_wallet), params: { amount: 200, destination_user_id: destination_wallet.user_id }
    assert_response :record_invalid
    source_wallet.reload
    destination_wallet.reload
    assert_equal 100, source_wallet.balance.to_f
    assert_equal 50, destination_wallet.balance.to_f
  end
end
