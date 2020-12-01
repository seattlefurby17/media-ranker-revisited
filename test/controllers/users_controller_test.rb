require "test_helper"

describe UsersController do
  # Tests written for Oauth.    
  describe "auth_callback" do
    it "logs in an existing user and redirects to the root path" do
      user = users(:ada)

      expect {
        perform_login(user)
      }.wont_change "User.count"

      must_redirect_to root_path
      expect(session[:user_id]).must_equal user.id
      expect(flash[:result_text]).must_equal "Welcome back user #{user.username}"
    end

    it "creates an account for a new user and redirects to the root route" do
      user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")

      expect {
        perform_login(user)
      }.must_differ "User.count", 1
      expect(flash[:result_text]).must_include "Hola new user #{user.username}" 

      must_redirect_to root_path

      # The new user's ID should be set in the session
      expect(session[:user_id]).must_equal User.last.id

    end

    it "will handle a request with invalid information" do
      user = User.new(provider: "github", uid: nil, username: nil, email: nil)

      expect {
        perform_login(user)
      }.wont_change "User.count"

      must_redirect_to root_path

      expect(flash[:result_text]).must_equal "Could not create a new user account: {:username=>[\"can't be blank\"]}"
      expect(session[:user_id]).must_equal nil
    end
  end

  describe "logout" do
    it "will log out a logged in user" do
      user = users(:grace)
      perform_login(user)

      delete logout_path

      expect(session[:user_id]).must_be_nil
      expect(flash[:result_text]).must_equal "Successfully logged out"
      must_redirect_to root_path
    end

    it "will redirect back and give a flash notice if a guest user tries to logout" do
      delete logout_path

      must_redirect_to root_path
      expect(session[:user_id]).must_equal nil
      expect(flash[:result_text]).must_equal "You were not logged in!"
    end
  end
end
