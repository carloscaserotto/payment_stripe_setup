class OrdersController < ApplicationController
  def index
    #byebug
    products = Product.all
    @products_purchase = products.where(stripe_plan_name:nil, paypal_plan_name:nil)
    @products_subscription = products - @products_purchase
  end

  def submit
    byebug
    @order = nil
    #Check which type of order it is
    if order_params[:payment_gateway] == "stripe"
      prepare_new_order
      #Orders::OrderSubmit.new(@order,current_user)
      #despues borrar las lineas de abajo--de aca---
      Stripe.api_key = Rails.application.credentials.stripe[:STRIPE_TEST_SECRET_KEY]
      #ejemplo para rails c---hay que usar la linea de arriba + la de abajo
      #Stripe::Plan.create({amount: 10000,interval: 'month',product: {name: 'Premium plan', }, currency: 'usd', id: 'premium-plan'})
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
        html_content = 'Su order fue procesadad con exito.<a href="http://localhost:3000/orders/">Volver a ordenes</a>'.html_safe
        html_nro_orden = "Nro de orden: #{@order.id} "
        return render html: html_content+html_nro_orden
        #"Su order fue procesadad con exito, #{@order.id} <a href="#segunda-seccion">Ir a la segunda sección</a>" #SUCCESS_MESSAGE
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

#Step 1: Create a plan using the Stripe API.
#Open your console using the command rails c . Create subscription for your Stripe account with:
#Stripe.api_key = Rails.application.credentials.stripe[:STRIPE_TEST_SECRET_KEY]
#Stripe::Plan.create({amount: 10000,interval: 'month',product: {name: 'Premium plan',},currency: 'usd',id: 'premium-plan'})
#para ver los productos que tengo:
#Stripe::Price.list({product: '{{PRODUCT_ID}}', active: true}) si lo pongo sin product me trae todo
#para crear un cliente y poder verlo en: https://dashboard.stripe.com/test/customers
#Stripe::Customer.create({description: 'My First Test Customer (created for API docs'})
#https://stripe.com/docs/api/customers/create?lang=ruby --> aca estan todos los parametros que podemos poner
#If the returned result in this step is true, it means that the plan was created successfully, 
#and you can access it in your - https://dashboard.stripe.com/test/subscriptions/products
#para buscar un cliente: 
#Stripe::Customer.retrieve('cus_MQlS76B4vFzpuG')
#Stripe::Customer.list({limit: 3}) -->list all customers
#Stripe::Customer.search({query: 'name:\'Carlu\'})
#Step 2: Create a product in the database with stripe_plan_name field set.
#Now, create a product with the stripe_plan_name set as premium-plan in the database:
#Product.create(price_cents: 10000, name: 'Premium Plan', stripe_plan_name: 'premium-plan')
#Step 3: Generate a migration for adding a column stripe_customer_id in the users table.
#------------AddStripeCustomerIdToUser stripe_customer_id:string-------------
#rails generate migration AddStripeCustomerIdToUser stripe_customer_id:string
#rails db:migrate

=begin
Pasos para crear una subscripcion:
1- Stripe.api_key = Rails.application.credentials.stripe[:STRIPE_TEST_SECRET_KEY]
2- Stripe::Plan.create({amount: 7000,interval: 'month',product: {name: 'Medium plan',},currency: 'usd',id: 'medium-plan'})
plan_id --> "product": "prod_MQn8LLvR72XOVz",
3- Stripe::Customer.create({name: "Trini", description: 'My First Test Customer', email: "trini@gmail.com" })
"id": "cus_MQoW0aDkkzdyxc",
4- Stripe::PaymentMethod.create({type: 'card',card: {number: '4242424242424242',exp_month: 9,exp_year: 2023,cvc: '314'}})
"id": "pm_1Lhwu9CTmdncucGnRFCyEO3Q",
5- Stripe::PaymentMethod.attach('pm_1Lhwu9CTmdncucGnRFCyEO3Q',{customer: 'cus_MQoW0aDkkzdyxc'})
   Stripe::Customer.update('cus_MQoW0aDkkzdyxc',{invoice_settings: {default_payment_method: 'pm_1Lhwu9CTmdncucGnRFCyEO3Q'}})
6- Stripe::Subscription.create({plan: product.stripe_plan_name, customer: 'cus_MQnJcaEByQ0yXd'})
#product.stripe_plan_name ---> aca va el nombre del plan que esta en la db
#cancelar la subscripcion
7- Stripe::Subscription.update('sub_1LhwwsCTmdncucGnfRFDINXH', {cancel_at_period_end: true}) 

#Listar los metodos de pago:
Stripe::Customer.list_payment_methods('cus_MQnJcaEByQ0yXd',{type: 'card'})
#Quitar un metodo de pago
Stripe::PaymentMethod.detach('pm_1LhwEGCTmdncucGnxdSb6eUh')

https://stripe.com/docs/api/customers/retrieve?lang=ruby
https://stripe.com/docs/api/payment_methods/object
https://stripe.com/docs/api/payment_methods/list
https://stripe.com/docs/billing/subscriptions/cancel
=end

=begin
Pasos para cobrar un producto:
1- Stripe.api_key = Rails.application.credentials.stripe[:STRIPE_TEST_SECRET_KEY]
2- Stripe::PaymentIntent.create({amount: 2000,currency: 'usd',payment_method_types: ['card']})
#secret = 'pi_3LjiqYCTmdncucGn0NeodPar_secret_KFNXP2tmHqGpCLBx4jhqHcNy3'
#Stripe::PaymentIntent.retrieve("pi_3LhxLvCTmdncucGn1ofKfi0K")
# To create a PaymentIntent for confirmation, see our guide at: https://stripe.com/docs/payments/payment-intents/creating-payment-intents#creating-for-automatic
3- Stripe::PaymentIntent.confirm('pi_3Li0QsCTmdncucGn1EVuxvAN', {payment_method: 'pm_card_visa'})
=end
#payment con customer ID
#Stripe::PaymentIntent.create({amount: 2000,currency: 'usd',customer: 'cus_MQoW0aDkkzdyxc', payment_method_types: ['card']})

=begin
nuevo - - Pasos para cobrar un producto:
Stripe.api_key = Rails.application.credentials.stripe[:STRIPE_TEST_SECRET_KEY]
Creo el cliente en sistema
Stripe::Customer.create({name: "Trini", description: 'My First Test Customer', email: "trini@gmail.com" })
Me retorna un "id": "cus_MREoz4CYOhXx5c"
Creo un metodo de pago
Stripe::PaymentMethod.create({type: 'card',card: {number: '4242424242424242',exp_month: 12,exp_year: 2027,cvc: '514'}})
Me retorna un "id": "pm_1LiMTvCTmdncucGnHRqXvbvQ"
Adjunto el metodo de pago al cliente
Stripe::PaymentMethod.attach('pm_1LiMTvCTmdncucGnHRqXvbvQ',{customer: 'cus_MREoz4CYOhXx5c'})
Adjunto el metodo de pago al cliente
Stripe::Customer.update('cus_MREoz4CYOhXx5c',{invoice_settings: {default_payment_method: 'pm_1LiMTvCTmdncucGnHRqXvbvQ'}})
Stripe::Customer.retrieve('cus_MREoz4CYOhXx5c')
Aca es donde creo un intento de pago con el id del cliente y el id de metodo de pago:
Stripe::PaymentIntent.create({amount: 2000,customer: 'cus_MREoz4CYOhXx5c',payment_method:'pm_1LiMTvCTmdncucGnHRqXvbvQ', currency: 'usd',payment_method_types: ['card']})
Retorna un "id": "pi_3LiMZ1CTmdncucGn1ItOBj33"
Con ese id confirmo el pago:
Stripe::PaymentIntent.confirm('pi_3LiMZ1CTmdncucGn1ItOBj33')
=end