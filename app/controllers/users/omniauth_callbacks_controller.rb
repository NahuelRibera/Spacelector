# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  def google_oauth2
    return redirect_to_email_login if auth.blank?

    user = User.from_omniauth(auth)

    if user.present?
      sign_out_all_scopes
      flash[:success] = t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect user, event: :authentication
    else
      flash[:alert] =
        t 'devise.omniauth_callbacks.failure', kind: 'Google', reason: "#{auth.info.email} is not authorized. Please use a different account."
      redirect_to new_user_session_path
    end
  end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # POST /users/auth/google_oauth2 only lands here when no OmniAuth strategy intercepted it,
  # i.e. GOOGLE_CLIENT_ID/SECRET aren't set. Devise's default is a bare 404.
  def passthru
    redirect_to_email_login
  end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end

  private

  def auth
    @auth ||= request.env['omniauth.auth']
  end

  def redirect_to_email_login
    redirect_to new_user_session_path, alert: t('devise.omniauth_callbacks.not_configured', kind: 'Google')
  end
end
