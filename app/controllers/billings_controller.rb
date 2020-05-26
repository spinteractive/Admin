class BillingsController < ApplicationController
	rescue_from Stripe::CardError, with: :catch_exception
  skip_before_action :verify_authenticity_token, only: :payment_failed

	def index
	end

  def checkout
    StripeChargesServices.new(charges_params, current_user).call
    flash[:success] = "Amount paid successfully"
    redirect_to billings_path
  end

  def payment_failed
    payload = request.body.read
    data = JSON.parse(payload, symbolize_names: true)
    event = Stripe::Event.construct_from(data)

    return unless event['type'] == 'invoice.payment_failed'

    ServerService.new.stop
  end

  private

  def charges_params
    params.permit(:card_number, :card_verification, :exp_month, :exp_year, :stripeToken)
  end

  def catch_exception(exception)
    flash[:error] = exception.message
    redirect_to billings_path
  end
end
