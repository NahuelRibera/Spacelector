module ApplicationHelper
  # True only when GOOGLE_CLIENT_ID/SECRET were present at boot (see config/initializers/devise.rb).
  def google_oauth_enabled?
    Devise.omniauth_configs.key?(:google_oauth2)
  end
end
