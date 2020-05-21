class StripeChargesServices
  DEFAULT_CURRENCY = 'usd'.freeze
  
  def initialize(params, user)
    @stripe_token = params[:stripeToken]
    @user = user
  end

  def call
    create_subscription(find_customer)
  end

  private

  attr_accessor :user, :stripe_token, :order

  def create_subscription(customer)
    subscription = Stripe::Subscription.create(
      customer: customer.id,
      items: [{ price: 'price_HJvwrEG3aCt1Mn' }],
      expand: ['latest_invoice.payment_intent']
    )
    Rails.logger.info(subscription.inspect)
    byebug
    user.update(subscription_token: subscription.id)
    subscription
  end

  def find_customer
    if user.stripe_token
      retrieve_customer(user.stripe_token)
    else
      create_customer
    end
  end

  def retrieve_customer(stripe_token)
    Stripe::Customer.retrieve(stripe_token) 
  end

  def create_customer
    customer = Stripe::Customer.create(
      email: @user.email,
      source: stripe_token
    )
    user.update(stripe_token: customer.id)
    customer
  end
end
