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
      flash[:success] = "Welcome back returning user #{user.username}"
    else
      # User doesn't exist in the DB
      # Attempt to create a new user
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:success] = "Hola new user #{user.username}" 
      else # Display error - easier debugging
        flash[:error] = "Could not create a new user account: #{user.errors.messages}" 
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
    session[:user_id] = nill
    flash[:success] = "Successfully logged out"
    redirect_to root_path
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
