class BillingsController < ApplicationController
	rescue_from Stripe::CardError, with: :catch_exception
  skip_before_action :verify_authenticity_token, only: :payment_failed
  authorize_resource class: false, except: :payment_failed

	def index
	end

  def checkout
    success = StripeChargesServices.new(charges_params, current_user).call
    if success
      flash[:success] = 'Subscribed successfully'
    else
      flash[:alert] = 'Card authorization failed'
    end

    redirect_to billings_path
  end

  def payment_failed
    payload = request.body.read
    signature_header = request.env['HTTP_STRIPE_SIGNATURE']
    webhook_secret = Rails.application.secrets.stripe_webhook_secret
    event = Stripe::Webhook.construct_event(payload, signature_header, webhook_secret)

    return unless event['type'] == 'invoice.payment_failed'

    user = User.find_by(stripe_token: event.data.object.customer)
    return unless user

    user.update(payment_success: false)
    ServerService.new(user.instance).stop
  rescue JSON::ParserError
    head :bad_request
  rescue Stripe::SignatureVerificationError
    logger.info 'Webhook signature verification failed.'
    head :bad_request
  end


  private

  def charges_params
    params.permit(:card_number, :card_verification, :exp_month, :exp_year, :stripeToken)
  end

  def catch_exception(exception)
    flash[:alert] = exception.message
    redirect_to billings_path
  end
end
