module Orders
    class CreateService
        include ServiceResponse

        def initialize(order_params, customer_params, coupon_params)
            @order_params = order_params[:items]
            @idempotency_key = order_params[:idempotency_key]
            @customer_params = customer_params
            @coupon_params = coupon_params || {}
        end

       def call
            return error("Invalid order parameters.") unless @order_params && @customer_params
            return error("Customer name is required.") if @customer_params[:customer_name].blank?
            return error("Customer email is required.") if @customer_params[:customer_email].blank?
            return error("Order must contain at least one item.") if @order_params.empty?
            return not_found("Book not found.") unless @order_params.all? { |item| Book.exists?(id: item[:book_id]) }
            return error("Idempotency key is required") if @idempotency_key.blank?

            existing_order = Order.find_by(idempotency_key: @idempotency_key)
            return ok("Duplicate order", order: serialize_order(existing_order)) if existing_order

            order = nil

            ActiveRecord::Base.transaction do
                order = build_order
                order.save!

                total_price = process_order_items!(order)

                order.update!(
                total_price: total_price,
                original_amount: total_price
                )

                apply_coupon!(order)
            end

            success(order: serialize_order(order))
            rescue ActiveRecord::RecordInvalid => e
            error("Failed to create order: #{e.record.errors.full_messages.join(', ')}")
            rescue StandardError => e
            error("Failed to create order: #{e.message}")
        end

        private 
        def build_order
            order = Order.new(
                customer_name: @customer_params[:customer_name],
                customer_email: @customer_params[:customer_email],
                idempotency_key: @idempotency_key
            )

            order.order_items = @order_params.map do |item|
                book = Book.find(item[:book_id])
                quantity = item[:quantity].to_i

                OrderItem.new(
                book_id: book.id,
                quantity: quantity,
                unit_price: book.price,
                subtotal: book.price * quantity
                )
            end

            order
        end

        def process_order_items!(order)
            total_price = 0

            order.order_items.each do |item|
                item.book.with_lock do
                item.book.reload

                if item.book.stock < item.quantity.to_i
                    raise StandardError, "Insufficient stock for book #{item.book.title}"
                end

                item.book.stock -= item.quantity.to_i
                item.book.save!

                total_price += item.subtotal
                end
            end

            total_price
        end

        def apply_coupon!(order)
            return unless @coupon_params[:coupon_code].present?

            coupon_result = Coupons::ApplyService.new(@coupon_params, order).call

            unless [:ok, :created].include?(coupon_result[:status])
                raise StandardError, coupon_result[:error] || coupon_result[:message] || "Failed to apply coupon"
            end
        end

        def serialize_order(order)
            order.as_json(include: { order_items: { include: :book } })
        end
    end
end 
