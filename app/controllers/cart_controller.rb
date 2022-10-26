class CartController < ApplicationController
    def index
        @products = Product.all
    end

    def purchased
        #byebug
        #prepare_new_order
        @product_price = purchase_params[:price]
        @product_name = purchase_params[:order_number]
        token = purchase_params[:token]
        Stripe.api_key = Rails.application.credentials.stripe[:STRIPE_TEST_SECRET_KEY]
        pi = Stripe::PaymentIntent.create({amount: @product_price, currency: 'usd', payment_method_types: ['card']})
        Stripe::PaymentIntent.confirm(pi.id, {payment_method: 'pm_card_visa'})
        @mostrar = pi.id
    end

    def secret
        @pi = Stripe::PaymentIntent.create({amount: 1000, currency: 'usd', payment_method_types: ['card']})
        render json: @pi      
    end

    def confirm
        #byebug
        @id = params[:orders][:token]
        @confirm = Stripe::PaymentIntent.confirm(@id, {payment_method: 'pm_card_visa'})
        render json: @confirm
    end


    private

    def prepare_new_order
        @order = Order.new(order_params)
        @order.user_id = current_user.id
        @product = Product.find(@order.product_id)
        @order.price_cents = @product.price_cents
        @order.token = order_params[:token]
      end
    def purchase_params
        params.require(:orders).permit(:order_number, :token, :price, :card_number, :card_expiration_month, :card_expiration_year, :card_expiration_year, :card_cvc)
    end
end

