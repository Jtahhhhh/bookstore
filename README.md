# Bookstore Practice API

Bookstore Practice API is a Rails project I built to practice backend development through a small bookstore/e-commerce domain. The goal of this project is not to be a complete production product, but to break down familiar backend problems into focused exercises: book management, order checkout, flash sale reservations, coupons, wallets, payment webhooks, and tests.

This project helped me practice service objects, transactions, idempotency, stock locking to reduce overselling risk, and writing tests for important business cases.

## Tech Stack

- Ruby on Rails 8
- PostgreSQL
- Redis
- Devise
- Minitest
- Docker Compose

## What I Have Built

### Admin

- Manage books, authors, and categories.
- Manage orders and order items through a basic admin interface.
- Use Devise for user authentication.

### Public API

- Fetch published books.
- Search books by title.
- Filter books by author, category, and price range.
- Paginate book lists.
- View book details with author and categories.

### Order Checkout

- Create orders from a list of items.
- Validate customer name, customer email, and order items.
- Check that books exist before creating an order.
- Calculate unit price, subtotal, original amount, and total price.
- Decrease stock when an order is created successfully.
- Use `with_lock` while decreasing stock to reduce overselling risk.
- Add `idempotency_key` to order creation so retry requests are safer.
- Support applying coupons during checkout.

### Coupon

- Preview a coupon before applying it.
- Support percentage and fixed-amount discounts.
- Support minimum order amount, maximum discount amount, start/end time, active flag, and usage limit.
- Store coupon redemptions to prevent duplicate application.
- Increase `used_count` when a coupon is applied successfully.

### Flash Sale Reservation

- Create flash sales and flash sale items.
- Reserve flash sale stock through reservations.
- Use `idempotency_key` for reservations.
- Decrease flash sale item stock when a reservation succeeds.
- Schedule a job to expire reservations after a period of time.

### Wallet

- Deposit funds into a wallet.
- Withdraw funds from a wallet.
- Transfer funds between wallets.
- Record ledger entries for wallet transactions.
- Use transaction keys to prevent duplicate transaction processing.

### Payment Webhook

- Process successful, failed, and refunded payment webhooks.
- Store payment events.
- Use `event_id` to prevent duplicate webhook processing.

### Tests

The project includes tests for several layers of logic:

- Model validations.
- API controllers.
- Order checkout service.
- Coupon preview/apply service.
- Reservation service.
- Payment webhook service.
- Wallet flows.
- Reservation expiration background job.

## Main API Endpoints

### Books

```http
GET /api/books
GET /api/books/:id
```

Supported query params:

- `q`
- `author_id`
- `category`
- `min_price`
- `max_price`
- `page`
- `per_page`

### Orders

```http
POST /api/orders
```

Example payload:

```json
{
  "order": {
    "idempotency_key": "checkout-001",
    "customer_name": "Van Thanh",
    "customer_email": "thanh@example.com",
    "coupon_code": "RUBY20",
    "items": [
      {
        "book_id": 1,
        "quantity": 2
      }
    ]
  }
}
```

### Coupons

```http
POST /api/coupons/preview
```

### Flash Sale Reservations

```http
POST /api/flash_sales/:flash_sale_id/reservations
```

### Wallets

```http
POST /api/wallets/:id/deposit
POST /api/wallets/:id/withdraw
POST /api/wallets/:id/transfer
```

### Payment Webhook

```http
POST /api/webhooks/payments
```

## Running The Project

```bash
docker compose up --build
```

The server runs at:

```text
http://localhost:3000
```

Run migrations:

```bash
docker compose exec web bin/rails db:migrate
```

Seed sample data:

```bash
docker compose exec web bin/rails db:seed
```

Run the test suite:

```bash
docker compose exec web bin/rails test
```

Run a single test file:

```bash
docker compose exec web bin/rails test test/services/orders/create_service_test.rb
```

## Next Practice Goals

- Add more controller tests for order checkout.
- Standardize response contracts across services.
- Add happy-path tests for checkout with a valid coupon.
- Clarify the payment flow after an order is created.
- Improve error handling by separating business errors from system errors.
- Write more detailed API documentation or add a Postman collection.

## Notes

This is a learning project, so some parts can still be refactored. I use it to practice thinking through real backend flows: input data, validation, transactions, idempotency, race conditions, response contracts, and tests.
