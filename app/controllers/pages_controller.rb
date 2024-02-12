class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @portal_session = current_user.payment_processor.billing_portal
  end
end
