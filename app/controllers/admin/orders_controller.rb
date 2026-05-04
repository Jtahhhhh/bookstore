class Admin::OrdersController < Admin::BaseController
    before_action :set_order, only: [:show, :edit, :update]

    def index
        @orders = Order.with_items.all.order(created_at: :desc)
    end

    def new
        @order = Order.new  
        @order.order_items.build
    end

    def create 
        @order = Order.new(order_params)
        Activerecord::Base.transaction do
             if @order.save!
                redirect_to admin_orders_path, notice: "Order created successfully."
             end
        rescue ActiveRecord::RecordInvalid => e
            flash.now[:alert] = "Failed to create order: #{e.message}"
            render :new
        end
    end

    def show 
    end

    def edit 
    end

    def update
        if @order.update(order_params)
            redirect_to admin_orders_path, notice: "Order updated successfully."
        else
            render :edit
        end
    end

    def destroy
        if @order.destroy
            redirect_to admin_orders_path, notice: "Order deleted successfully."
        else
            flash.now[:alert] = "Failed to delete order."
        end
    end

    private
    def set_order
        @order = Order.with_items.find(params[:id])
    end

    def order_params
        params.require(:order).permit(
            :customer_name,
            :customer_email,
            :status,
            order_items_attributes: [
                :id,
                :book_id,
                :quantity,
                :unit_price,
                :subtotal,
                :_destroy
            ]
        )
    end
end
