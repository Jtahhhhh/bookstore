module Orders
    class CreateService
        include ServiceResponse
        include Coupons
        def initialize(order_params, customer_params,coupon_params)
            @order_params = order_params[:items]
            @customer_params = customer_params
            @coupon_params = coupon_params
        end

        def call
            return error("Invalid order parameters.") unless @order_params && @customer_params
            return error("Customer name is required.") if @customer_params[:customer_name].blank?
            return error("Customer email is required.") if @customer_params[:customer_email].blank? && @customer_params[:customer_email].match?(/\A[^@\s]+@[^@\s]+\.[^@\s]+\z/)
            return error("Customer name is required.") if @customer_params[:customer_name].blank?
            return error("Order must contain at least one item.") if @order_params.empty?

            order = Order.new(customer_name: @customer_params[:customer_name], customer_email: @customer_params[:customer_email])
            order.order_items = @order_params.map do |item|
                book = Book.find_by(id: item[:book_id])
                return not_found("Book not found: #{item[:book_id]}") unless book.present?

                if book.stock < item[:quantity].to_i
                    return error("Insufficient stock for book #{book.id}")
                end

                OrderItem.new(
                    book_id: item[:book_id],
                    quantity: item[:quantity],
                    unit_price: Book.find(item[:book_id]).price
                )
            end
            ActiveRecord::Base.transaction do
            if order.save!
                order.order_items.each do |item|
                    item.book.stock -= item[:quantity]
                    item.book.save!
                end 
                if @coupon_params.present?
                    coupon_result = Coupons::ApplyService.new(
                        @coupon_params.to_h.symbolize_keys.merge(
                            order: {
                                order_id: order.id,
                                items: order.order_items
                            }
                        )
                    ).call
                    raise ActiveRecord::Rollback if coupon_result[:status] != :ok
                end
                return success(order: order.as_json(include: { order_items: { include: :book } }))
            end
           rescue ActiveRecord::RecordInvalid => e
                return error("Failed to create order: #{e.message}")
            end
        end
    end
end 
