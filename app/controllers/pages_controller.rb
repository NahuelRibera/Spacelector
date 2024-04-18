class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :terms_and_conditions ]

  def home
    @portal_session = current_user.payment_processor.billing_portal
  end

  def terms_and_conditions
    # Any logic or data retrieval for the terms and conditions page can go here
  end
end
