class CheckoutsController < ApplicationController
  before_action :authenticate_user!

  # app/controllers/checkouts_controller.rb

  def show
    current_user.set_payment_processor :stripe
    current_user.payment_processor.customer
  end

  def checkout
    plan_id = params[:plan] == 'annual' ? 'price_1OjLDVDT88Wq6H335atoBla0' : 'price_1OifPODT88Wq6H33t1AHmxom'

    @checkout_session = current_user
                        .payment_processor
                        .checkout(
                          mode: 'subscription',
                          line_items: [plan_id],
                          success_url: checkout_success_url
                        )

    redirect_to @checkout_session.url, allow_other_host: true
  end

  def success
    @session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @line_items = Stripe::Checkout::Session.list_line_items(params[:session_id])
  end
end
