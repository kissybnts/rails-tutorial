require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post signup_path, params: { user: { name: "", email: "invalid@invalid", password: "123", password_confirmation: "456" } }
    end
    assert_template 'users/new'
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: {
        user: {
          name: "Michel",
          email: "valid@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?

    log_in_as(user)
    assert_not is_logged_in?

    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?

    get edit_account_activation_path(user.activation_token, email: "wrong address")
    assert_not is_logged_in?

    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
