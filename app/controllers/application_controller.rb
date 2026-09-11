class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] || session[:locale] || I18n.default_locale
    session[:locale] = I18n.locale
  end

  def default_url_options
    { locale: I18n.locale }
  end

  # Scopes an Image lookup to the current user's own spaces, so changing an id
  # in the URL can't expose or affect another user's image/compartments/annotations.
  def find_owned_image(id)
    Image.joins(:space).merge(current_user.spaces).find(id)
  end

  private

  # This method is called by Devise to determine the path after sign out.
  def after_sign_out_path_for(resource_or_scope)
    spaces_path # This assumes you have a spaces_index_path defined in your routes.
  end
end
