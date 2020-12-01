class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def create # same as login
    auth_hash = request.env['omniauth.auth'] 
    user = User.find_by(uid: auth_hash[:uid], provider: 'github')
    if user # existing user
      flash[:status] = :success
      flash[:result_text] = "Welcome back user #{user.username}"
    else
      # User doesn't exist in the DB
      # Attempt to create a new user
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:status] = :success
        flash[:result_text] = "Hola new user #{user.username}" 
      else # Display error - easier debugging
        flash[:status] = :failure
        flash[:result_text] = "Could not create a new user account: #{user.errors.messages}" 
        redirect_to root_path
        return
      end
    end

    # If we get here, we have a valid merchant instance
    session[:user_id] = user.id
    redirect_to root_path
    return
  end

  def destroy # same as logout
    if session[:user_id]
      session[:user_id] = nil
      flash[:status] = :success
      flash[:result_text] = "Successfully logged out"
    else
      flash[:status] = :failure
      flash[:result_text] = "You were not logged in!"
    end
    redirect_to root_path
    return
  end

  # def login_form
  # end

  # def login
  #   username = params[:username]
  #   if username and user = User.find_by(username: username)
  #     session[:user_id] = user.id
  #     flash[:status] = :success
  #     flash[:result_text] = "Successfully logged in as existing user #{user.username}"
  #   else
  #     user = User.new(username: username)
  #     if user.save
  #       session[:user_id] = user.id
  #       flash[:status] = :success
  #       flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
  #     else
  #       flash.now[:status] = :failure
  #       flash.now[:result_text] = "Could not log in"
  #       flash.now[:messages] = user.errors.messages
  #       render "login_form", status: :bad_request
  #       return
  #     end
  #   end
  #   redirect_to root_path
  # end

  # def logout
  #   session[:user_id] = nil
  #   flash[:status] = :success
  #   flash[:result_text] = "Successfully logged out"
  #   redirect_to root_path
  # end
end
