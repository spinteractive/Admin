class StripeUsageService
  def call
    User.where.not(subscription_token: nil).each do |user|
      usage_in_hours = ServerService.new(user.instance).status['hours']
      send_usage_to_stripe(usage_in_hours, user)
    end
  end

  private

  def send_usage_to_stripe(hours, user)
    Stripe::SubscriptionItem.create_usage_record(
      user.subscription_token,
      { quantity: hours.to_i, timestamp: Time.now.to_i, action: 'set' }
    )
  end
end
