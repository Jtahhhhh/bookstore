module Coupons
  class ApplyService
    include ServiceResponse
    def initialize(attribute, order)
      attribute = attribute.to_h.with_indifferent_access

      @coupon_code = attribute[:coupon_code]
      @user_id = attribute[:user_id]
      @order = order
      @idempotency_key = "order_coupon:#{order.id}:#{@coupon_code}"
    end

    def call
      return error("Idempotency key is required") if @idempotency_key.blank?

      coupon = Coupon.active.find_by(code: @coupon_code)
      return not_found("Coupon not found") unless coupon.present?

      return_existing_redemption if existing_redemption.present?

      return error("Coupon not started") if coupon.starts_at > Time.current
      return error("Coupon expired") if coupon.ends_at < Time.current

      original_amount = calculate_original_amount(@order.order_items)

      if coupon.min_order_amount.present? && original_amount < coupon.min_order_amount
        return error("Order amount does not meet minimum requirement")
      end

      discount_amount = calculate_discount_amount(coupon, original_amount)
      final_amount = calculate_final_amount(original_amount, discount_amount)

      redemption = nil

      ActiveRecord::Base.transaction do
        coupon.with_lock do
          coupon.reload

          if coupon.usage_limit.present? && coupon.used_count >= coupon.usage_limit
            raise ActiveRecord::Rollback
          end

          redemption = coupon.coupon_redemptions.create!(
            user_id: @user_id,
            order_id: @order.id,
            idempotency_key: @idempotency_key,
            discount_amount: discount_amount,
            original_amount: original_amount,
            final_amount: final_amount
          )

          @order.update!(
            original_amount: original_amount,
            discount_amount: discount_amount,
            total_price: final_amount
          )

          coupon.used_count += 1
          coupon.save!
        end
      end

      return error("Coupon usage limit reached") unless redemption.present?

      success("Coupon applied successfully", redemption_response(redemption))

    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => e
      existing = CouponRedemption.find_by(idempotency_key: @idempotency_key)
      return return_existing_redemption if existing
      error(e.message)
    end

    private

    def existing_redemption
      @existing_redemption ||= CouponRedemption.find_by(idempotency_key: @idempotency_key)
    end

    def return_existing_redemption
      ok("Coupon already applied", redemption_response(existing_redemption))
    end

    def redemption_response(redemption)
      {
        redemption_id: redemption.id,
        coupon_code: @coupon_code,
        original_amount: redemption.original_amount,
        discount_amount: redemption.discount_amount,
        final_amount: redemption.final_amount
      }
    end

    def calculate_original_amount(items)
      items.sum(&:subtotal)
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