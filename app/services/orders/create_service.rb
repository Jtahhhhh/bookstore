module Orders
    class CreateService
        include ServiceResponse

        def initialize(order_params, customer_params)
            @order_params = order_params[:items]
            @customer_params = customer_params
        end

        def call
            return error("Invalid order parameters.") unless @order_params && @customer_params
            return error("Customer name is required.") if @customer_params[:customer_name].blank?
            return error("Customer email is required.") if @customer_params[:customer_email].blank?
            return error("Order must contain at least one item.") if @order_params.empty?

            order = Order.new(customer_name: @customer_params[:customer_name], customer_email: @customer_params[:customer_email])
            order.order_items = @order_params.map do |item|
                OrderItem.new(
                    book_id: item[:book_id],
                    quantity: item[:quantity],
                    unit_price: Book.find(item[:book_id]).price
                )
            end
            order.order_items.each do |item|

                return not_found("Book not found: #{item[:book_id]}") unless item.book

                if item.book.stock < item[:quantity].to_i
                    return error("Insufficient stock for book #{item.book.id}")
                end
            end
            
            ActiveRecord::Base.transaction do
            if order.save!
                order.order_items.each do |item|
                    item.book.stock -= item[:quantity]
                    item.book.save!
                end
                return success(order: order.as_json(include: { order_items: { include: :book } }))
            end
           rescue ActiveRecord::RecordInvalid => e
                return error("Failed to create order: #{e.message}")
            end
        end
    end
end 
