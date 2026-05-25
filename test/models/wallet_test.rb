require "test_helper"

class WalletTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should create wallet with valid attributes" do
    wallet = Wallet.new(user_id: create_user.id, balance: 100)
    assert wallet.save
  end

  test "should not create wallet without user_id" do
    wallet = Wallet.new(balance: 100)
    assert_not wallet.save
  end

  test "should not create wallet with duplicate user_id" do
    user = create_user
    Wallet.create!(user_id: user.id, balance: 100)
    wallet = Wallet.new(user_id: user.id, balance: 50)
    assert_not wallet.save
  end

  test "should not create wallet with negative balance" do
    wallet = Wallet.new(user_id: create_user.id, balance: -100)
    assert_not wallet.save
  end

  test "should add funds and create ledger entry" do
    wallet = Wallet.create!(user_id: create_user.id, balance: 100)
    wallet.add_funds(50, "test_transaction_key", { note: "Test deposit" })
    assert_equal 150, wallet.balance.to_f
    assert_equal 1, wallet.ledger_entries.count
    assert_equal "credit", wallet.ledger_entries.first.entry_type
    assert_equal 50, wallet.ledger_entries.first.amount.to_f
  end

  test "should deduct funds and create ledger entry" do 
    wallet = Wallet.create!(user_id: create_user.id, balance: 100)
    wallet.deduct_funds(30, "test_transaction_key_2", { note: "Test withdrawal" })
    assert_equal 70, wallet.balance.to_f
    assert_equal 1, wallet.ledger_entries.count
    assert_equal "debit", wallet.ledger_entries.first.entry_type
    assert_equal 30, wallet.ledger_entries.first.amount.to_f
  end

  private

  def create_user
    User.create!(
      email: "wallet-#{SecureRandom.hex(4)}@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end
end
