require "test_helper"

class LedgerEntryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "should create ledger entry with valid attributes" do
    wallet = Wallet.create!(user_id: create_user.id, balance: 100)
    ledger_entry = LedgerEntry.new(
      wallet: wallet,
      transaction_key: "test_transaction_key_3",
      entry_type: "credit",
      amount: 50,
      balance_after: 150,
      meta_data: { note: "Test ledger entry" }
    )
    assert ledger_entry.save
  end

  test "should not create ledger entry without transaction_key" do
    wallet = Wallet.create!(user_id: create_user.id, balance: 100)
    ledger_entry = LedgerEntry.new(
      wallet: wallet,
      entry_type: "debit",
      amount: 30,
      balance_after: 70,
      meta_data: { note: "Test ledger entry without transaction key" }
    )
    assert_not ledger_entry.save
  end

  test "should not create ledger entry with duplicate transaction_key" do
    wallet = Wallet.create!(user_id: create_user.id, balance: 100)
    LedgerEntry.create!(
      wallet: wallet,
      transaction_key: "test_transaction_key_4",
      entry_type: "credit",
      amount: 50,
      balance_after: 150,
      meta_data: { note: "First ledger entry" }
    )
    duplicate_ledger_entry = LedgerEntry.new(
      wallet: wallet,
      transaction_key: "test_transaction_key_4",
      entry_type: "debit",
      amount: 30,
      balance_after: 120,
      meta_data: { note: "Duplicate ledger entry" }
    )
    assert_not duplicate_ledger_entry.save
  end

  private

  def create_user
    User.create!(
      email: "ledger-#{SecureRandom.hex(4)}@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end
end
