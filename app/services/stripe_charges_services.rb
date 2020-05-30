class StripeChargesServices
  DEFAULT_CURRENCY = 'usd'.freeze
  BILLING_TIME_ZONE = '+00:00'
  
  def initialize(params, user)
    @stripe_token = params[:stripeToken]
    @user = user
  end

  def call
    subscription = create_subscription(find_customer)
    subscription.pending_setup_intent.nil?
  end

  private

  attr_accessor :user, :stripe_token, :order

  def create_subscription(customer)
    now = Time.now.getlocal(BILLING_TIME_ZONE)
    end_of_period = Time.new(now.year, now.month + 1, 1, 0, 0, 0, BILLING_TIME_ZONE)

    subscription = Stripe::Subscription.create(
      customer: customer.id,
      items: [{ price: Rails.configuration.x.stripe.price_id }],
      billing_cycle_anchor: end_of_period.to_i,
      expand: ['pending_setup_intent']
    )

    user.update(subscription_token: subscription.items.first.id)

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
