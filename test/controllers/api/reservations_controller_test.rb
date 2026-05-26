require "test_helper"

class Api::ReservationsControllerTest < ActionDispatch::IntegrationTest
  test "creates reservation from top-level idempotency key and items" do
    sign_in_test_user
    flash_sale = flash_sales(:active_sale)
    sale_item = flash_sale_items(:ruby_sale_item)

    post api_flash_sale_reservations_path(flash_sale),
      params: {
        idempotency_key: "request-success-key",
        items: [
          { book_id: sale_item.book_id, quantity: 1 }
        ]
      },
      as: :json

    assert_response :created

    body = JSON.parse(response.body)
    assert body["reservation"], "response should include reservation data"
  end

  test "returns validation error when idempotency key is missing" do
    sign_in_test_user
    flash_sale = flash_sales(:active_sale)
    sale_item = flash_sale_items(:ruby_sale_item)

    post api_flash_sale_reservations_path(flash_sale),
      params: {
        items: [
          { book_id: sale_item.book_id, quantity: 1 }
        ]
      },
      as: :json

    assert_response :unprocessable_entity

    body = JSON.parse(response.body)
    assert_match "Idempotency key", body["error"]
  end
end
