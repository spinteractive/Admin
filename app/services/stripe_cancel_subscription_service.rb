class StripeCancelSubscriptionService
  def initialize(user)
    @user = user
  end

  def call
    subscription_id = fetch_subscription_id(@user.subscription_token)
    cancel_subscription(subscription_id)

    @user.update(payment_success: false)
    ServerService.new(@user.instance).stop
  end

  def cancel_subscription(id)
    Stripe::Subscription.update(id, cancel_at_period_end: true)
  end

  def fetch_subscription_id(item_id)
    item = Stripe::SubscriptionItem.retrieve(item_id)
    item.subscription
  end
end
