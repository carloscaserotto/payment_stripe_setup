# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


  def submit
    #byebug
    @order = nil
    #Check which type of order it is
    if order_params[:payment_gateway] == "stripe"
      prepare_new_order
      #Orders::OrderSubmit.new(@order,current_user)
      #despues borrar las lineas de abajo--de aca---
      Stripe.api_key = Rails.application.credentials.stripe[:STRIPE_TEST_SECRET_KEY]
      token = order_params[:token]
      charge = Stripe::Charge.create({amount: @product.price_cents,currency: "usd",description: @product.name,source: token})
      @order.charge_id = charge.id
      @order.set_paid
      #hasta aca---------------------------------------------
    elsif order_params[:payment_gateway] == "paypal"
      #PAYPAL WILL BE HANDLED HERE
    end
  ensure
    #byebug
    if @order&.save
      if @order.paid?
        # Success is rendered when order is paid and saved
        return render html: "Su order fue procesadad con exito, #{@order.id}" #SUCCESS_MESSAGE
      elsif @order.failed? && !@order.error_message.blank?
        # Render error only if order failed and there is an error_message
        return render html: @order.error_message
      end
    end
    render html: "hubo un error"#FAILURE_MESSAGE
    
  end

  private
  # Initialize a new order and and set its user, product and price.
  def prepare_new_order
    @order = Order.new(order_params)
    @order.user_id = current_user.id
    @product = Product.find(@order.product_id)
    @order.price_cents = @product.price_cents
    @order.token = order_params[:token]
  end

  def order_params
    params.require(:orders).permit(:product_id, :token, :payment_gateway, :charge_id)
  end
end


####################################################################################################
<div>
  <h1>List of products</h1>
  <%= form_tag({:controller => "orders", :action => "submit" }, {:id => 'order-details'}) do %>
    <input id="order-type" name="orders[payment_gateway]" type="hidden" value="stripe">
    <div class="form_row">
      <h4>Charges/Payments</h4>
      <% @products_purchase.each do |product| %>
        <%= radio_button_tag 'orders[product_id]', product.id, @products_purchase.first == product %>
        <span id="radioButtonName<%= product.id %>">#{product.name}</span>
        <span data-price="<%= product.price_cents %>" id="radioButtonPrice<%= product.id %>">#{humanized_money_with_symbol product.price}</span>
      <% end %>
    </div>
    <h4>Subscriptions
      <% @products_subscription.each do |product| %>
        <div>
          <%= radio_button_tag 'orders[product_id]', product.id, false %>
          <span id="radioButtonName<%= product.id %>">#{product.name}</span>
          <span data-price="<%= product.price_cents %>" id="radioButtonPrice<%= product.id %>">#{humanized_money_with_symbol product.price}</span>
        </div>
        <br/>
      <% end %>
    </h4>
    <h1>Payment Method</h1>
    <div class="form_row">
      <div><%= radio_button_tag 'payment-selection', 'stripe', true, onclick: "changeTab();" %>
           <span>Stripe</span>
      </div><br/>
      <div><%= radio_button_tag 'payment-selection', 'paypal', false, onclick: "changeTab();" %>
           <span>Paypal</span>
      </div>
    </div>
    <br/>
    <div class="paymentSelectionTab active" id="tab-stripe">
      <div id="card-element"></div>
      <div id="card-errors" role="alert"></div>
      <br/>
      <br/>
      <%= submit_tag "Buy it!", id: "submit-stripe" %>
    </div>
    <div class="paymentSelectionTab" id="tab-paypal">
      <div id="submit-paypal"></div>
    </div>
    <br/>
    <br/>
    <hr/>
  
  <% end %>
</div>