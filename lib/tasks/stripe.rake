namespace :stripe do
  desc 'Sends servers usage to Stripe'
  task usage: :environment do
    puts 'Sending server usage to Stripe...'
    StripeUsageService.new.call
  end
end
