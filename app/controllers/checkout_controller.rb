class CheckoutController < ApplicationController

    def order
        #byebug
        @order_number = 'ORD1000'
        @total_price = 5000
        @current_user = current_user.email
        Stripe.api_key = Rails.application.credentials.stripe[:STRIPE_TEST_SECRET_KEY]
        
        
       
    end

    def secret
        @total_price = 5000
        @pi = Stripe::PaymentIntent.create({amount: @total_price, currency: 'usd', automatic_payment_methods: {enabled: true}})
        render json: @pi      
    end

    def confirm
        #byebug
        @order_number = 'ORD1000'
        @total_price = 5000
        @current_user = current_user.email
        @pi = params[:payment_intent_client_secret]
        @pi_client_secret = params[:payment_intent_client_secret]
        if params[:redirect_status] == 'requires_payment_method'
            render 'http://localhost:3000/checkout'    
        else 
            @status = params[:redirect_status]
        end
    end

    private


end
