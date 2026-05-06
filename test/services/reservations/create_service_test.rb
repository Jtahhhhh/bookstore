require "test_helper"

class Reservations::CreateServiceTest < ActiveSupport::TestCase
  test "creates reservation and decreases flash sale item stock" do
    flash_sale = flash_sales(:active_sale)
    sale_item = flash_sale_items(:ruby_sale_item)
    original_stock = sale_item.stock

    result = Reservations::CreateService.new(
      { idempotency_key: "reserve-success-key" },
      [{ book_id: sale_item.book_id, quantity: 2 }],
      flash_sale.id
    ).call

    assert_equal :created, result[:status]
    assert_equal original_stock - 2, sale_item.reload.stock
    assert result[:reservation], "response should include reservation data"
  end

  test "returns existing reservation for same idempotency key" do
    flash_sale = flash_sales(:active_sale)
    existing = reservations(:pending_reservation)

    result = Reservations::CreateService.new(
      { idempotency_key: existing.idempotency_key },
      [{ book_id: flash_sale_items(:ruby_sale_item).book_id, quantity: 1 }],
      flash_sale.id
    ).call

    assert_equal :ok, result[:status]
    assert_equal existing.id, result.dig(:reservation, "id")
  end

  test "does not create reservation or change stock when stock is insufficient" do
    flash_sale = flash_sales(:active_sale)
    sale_item = flash_sale_items(:ruby_sale_item)
    sale_item.update!(stock: 1)

    assert_no_difference "Reservation.count" do
      result = Reservations::CreateService.new(
        { idempotency_key: "insufficient-stock-key" },
        [{ book_id: sale_item.book_id, quantity: 2 }],
        flash_sale.id
      ).call

      assert_equal :unprocessable_entity, result[:status]
      assert_match "Insufficient stock", result[:error]
    end

    assert_equal 1, sale_item.reload.stock
  end
end
