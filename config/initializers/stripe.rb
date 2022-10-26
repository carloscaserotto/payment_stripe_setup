=begin
Rails.application.configure do
    config.stripe.secret_key = ENV["STRIPE_SECRET_KEY"]
    config.stripe.publishable_key = ENV["STRIPE_PUBLISHABLE_KEY"]
end


Rails.configuration.stripe = {
    :publishable_key => Rails.application.credentials.stripe[:STRIPE_TEST_PUBLISHABLE_KEY],
    :secret_key => Rails.application.credentials.stripe[:STRIPE_TEST_SECRET_KEY]
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
=end

Rails.application.configure do
    config.stripe.secret_key = Rails.application.credentials.stripe[:STRIPE_TEST_SECRET_KEY],
    config.stripe.publishable_key = Rails.application.credentials.stripe[:STRIPE_TEST_PUBLISHABLE_KEY]
end