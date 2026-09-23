require "test_helper"
require "minitest/mock"

class AuthenticationTest < ActionDispatch::IntegrationTest
  GOOGLE_AUTHORIZE_PATH = "/users/auth/google_oauth2"

  def setup
    @user = User.create!(email: "someone@example.com", password: "password123")
  end

  test "email/password login works" do
    post user_session_path, params: { user: { email: @user.email, password: "password123" } }

    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal @user.id, controller.current_user&.id
  end

  test "a wrong password is rejected" do
    post user_session_path, params: { user: { email: @user.email, password: "wrong-password" } }

    assert_nil controller.current_user
  end

  # Google state is decided at boot from GOOGLE_CLIENT_ID/SECRET, so these stub the registered
  # providers rather than depending on whatever the developer has in their local .env.
  test "without Google credentials, no Google sign-in is offered" do
    Devise.stub(:omniauth_configs, {}) do
      get new_user_session_path
      assert_response :success
      assert_select "form[action^=?]", GOOGLE_AUTHORIZE_PATH, count: 0

      get root_path
      assert_response :success
      assert_select "form[action^=?]", GOOGLE_AUTHORIZE_PATH, count: 0
      assert_select "a[href^=?]", new_user_registration_path
    end
  end

  test "with Google credentials, Google sign-in is offered" do
    Devise.stub(:omniauth_configs, { google_oauth2: Object.new }) do
      get new_user_session_path
      assert_select "form[action^=?]", GOOGLE_AUTHORIZE_PATH, count: 1

      get root_path
      assert_select "form[action^=?]", GOOGLE_AUTHORIZE_PATH
    end
  end
end
