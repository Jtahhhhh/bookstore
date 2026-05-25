module Coupons 
    class PreviewService
        include ServiceResponse
        def initialize(attribute)
          @coupon_code = attribute[:coupon_code]
          @user_id = attribute[:user_id]
          @order = attribute[:order]
        end

        def call
            coupon = Coupon.active.find_by(code: @coupon_code )
            return not_found("Coupon not found") unless coupon.present?
            return error("Coupon not started") if coupon.starts_at > Time.current
            return error("Coupon expired") if coupon.ends_at < Time.current
            return error("Coupon usage limit reached") if coupon.used_count >= coupon.usage_limit
            original_amount = calculate_original_amount(@order[:items])
            return error("Order amount does not meet minimum requirement") if original_amount < coupon.min_order_amount
            discount_amount = calculate_discount_amount(coupon,original_amount)
            final_amout = calculate_final_amount(original_amount, discount_amount)
            return ok("Coupon can be applied", {
                "coupon_code": @coupon_code,
                "original_amount": original_amount,
                "discount_amount": discount_amount,
                "final_amount": final_amout,
            })
        end

        private 
        def calculate_original_amount(items)
            items.sum do |item|
                item[:unit_price].to_d * item[:quantity].to_i
            end
        end

        def calculate_discount_amount(coupon, original_amount)
            discount =
                case coupon.discount_type
                when "percentage"
                original_amount * coupon.discount_value / 100
                when "fixed_amount"
                coupon.discount_value
                else
                0.to_d
                end

            discount = [discount, coupon.max_discount_amount].min if coupon.max_discount_amount.present?
            [discount, original_amount].min
        end

        def calculate_final_amount(original_amount, discount_amount)
            original_amount - discount_amount
        end
    end
end
