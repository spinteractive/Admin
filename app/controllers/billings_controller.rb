class BillingsController < ApplicationController
	rescue_from Stripe::CardError, with: :catch_exception

	def index
	end

  def checkout
    StripeChargesServices.new(charges_params, current_user).call
    flash[:success] = "Amount paid successfully"
    redirect_to billings_path
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
