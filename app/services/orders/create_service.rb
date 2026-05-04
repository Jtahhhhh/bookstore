module Orders
    class CreateService
        def initialize(order_params, customer_params)
            @order_params = order_params[:items]
            @customer_params = customer_params
        end

        def call
            order = Order.new(customer_name: @customer_params[:customer_name], customer_email: @customer_params[:customer_email])
            order.order_items = @order_params.map do |item|
                OrderItem.new(
                    book_id: item[:book_id],
                    quantity: item[:quantity],
                    unit_price: Book.find(item[:book_id]).price
                )
            end
            return error_response("Order must contain at least one item.") if order.order_items.empty?
            order.order_items.each do |item|

                return not_found_response("Book not found: #{item[:book_id]}") unless item.book

                if item.book.stock < item[:quantity].to_i
                    return error_response("Insufficient stock for book #{item.book.id}")
                end
            end
            
            ActiveRecord::Base.transaction do
            if order.save!
                order.order_items.each do |item|
                    item.book.stock -= item[:quantity]
                    item.book.save!
                end
                return successful_response(order)
            end
           rescue ActiveRecord::RecordInvalid => e
                return error_response(raise ActiveRecord::Rollback, "Failed to create order: #{e.message}")
            end
        end
    
        private
        def successful_response(order)
            {
                status: :created,
                message: "Order created successfully",
                order: order.as_json(include: { order_items: { include: :book } })
            }
        end

        def not_found_response(error)
            {
                status: :not_found,
                error: error
            }
        end

        def error_response(error)
            {
                status: :unprocessable_entity,
                error: error
            }
        end
    end
end 
