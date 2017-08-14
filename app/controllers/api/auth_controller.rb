class Api::AuthController < Api::ApiController

  skip_before_action :authenticate_user, except: [:change_pw, :update]

  before_action {
    @user_manager = user_manager
  }

  def sign_in
    result = @user_manager.sign_in(params[:email], params[:password])
    if result[:error]
      render :json => result, :status => 401
    else
      render :json => result
    end
  end

  def register
    result = @user_manager.register(params[:email], params[:password], params)
    if result[:error]
      render :json => result, :status => 401
    else
      render :json => result
    end
  end

  def change_pw
    result = @user_manager.change_pw(current_user, params[:new_password], params)
    if result[:error]
      render :json => result, :status => 401
    else
      render :json => result
    end
  end

  def update
    result = @user_manager.update(current_user, params)
    if result[:error]
      render :json => result, :status => 401
    else
      render :json => result
    end
  end

  def auth_params
    auth_params = @user_manager.auth_params(params[:email])
    if !auth_params
      render :json => {:error => {:message => "Unable to locate account for email."}}, :status => 404
    else
      render :json => @user_manager.auth_params(params[:email])
    end
  end

end
