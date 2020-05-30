class StripeChargesServices
  DEFAULT_CURRENCY = 'usd'.freeze
  BILLING_TIME_ZONE = '+00:00'
  
  def initialize(params, user)
    @card_token = params[:stripeToken]
    @user = user
  end

  def call
    create_or_update_customer_with_card

    subscription = create_or_fetch_subscription

    success = subscription.pending_setup_intent.nil?
    @user.update(payment_success: success)

    success
  end

  private

  def create_or_update_customer_with_card
    if @user.stripe_token.nil?
      create_customer
    else
      update_customer
    end
  end

  def create_customer
    customer = Stripe::Customer.create(
      email: @user.email,
      source: @card_token
    )

    @user.update(stripe_token: customer.id)

    customer
  end

  def update_customer
    card = Stripe::Customer.create_source(
      @user.stripe_token,
      source: @card_token
    )

    Stripe::Customer.update(
      @user.stripe_token,
      default_source: card.id
    )
  end

  def create_or_fetch_subscription
    if @user.subscription_token.nil?
      create_subscription
    else
      fetch_subscription(@user.subscription_token)
    end
  end

  def create_subscription
    now = Time.now.getlocal(BILLING_TIME_ZONE)
    end_of_period = Time.new(now.year, now.month + 1, 1, 0, 0, 0, BILLING_TIME_ZONE)

    subscription = Stripe::Subscription.create(
      customer: @user.stripe_token,
      items: [{ price: Rails.configuration.x.stripe.price_id }],
      billing_cycle_anchor: end_of_period.to_i,
      expand: ['pending_setup_intent']
    )

    @user.update(subscription_token: subscription.items.first.id)

    subscription
  end

  def fetch_subscription(id)
    Stripe::Subscription.retrieve(id)
  end
end
