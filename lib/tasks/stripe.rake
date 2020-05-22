namespace :stripe do
  desc 'Sends servers usage to Stripe'
  task usage: :environment do
    StripeUsageService.new.call
  end
end
