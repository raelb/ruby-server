class Api::AuthController < Api::ApiController

  skip_before_action :authenticate_user, except: [:change_pw, :update]

  before_action {
    @user_manager = user_manager
  }

  def mfa_for_email(email)
    user = User.find_by_email(email)
    return if user == nil
    mfa = user.items.where("content_type" => "SF|MFA", "deleted" => false).first
    return mfa
  end

  def verify_mfa(email)
    mfa = mfa_for_email(params[:email])

    if mfa != nil
      mfa_content = mfa.decoded_content
      mfa_param_key = "mfa_#{mfa.uuid}"
      if params[mfa_param_key]
        # Client has provided mfa value
        received_code = params[mfa_param_key]
        totp = ROTP::TOTP.new(mfa_content["secret"])
        if !totp.verify(received_code)
          # Invalid MFA, abort login
          render :json => {
              :error => {
                :tag => "mfa-invalid",
                :message => "The two-factor authentication code you entered is incorrect. Please try again.",
                :payload => {:mfa_key => mfa_param_key}
              }
            }, :status => 401
            return false
        end
      else
        # Client needs to provide mfa value
        render :json => {
            :error => {
              :tag => "mfa-required",
              :message => "Please enter your two-factor authentication code.",
              :payload => {:mfa_key => mfa_param_key}
            }
          }, :status => 401
        return false
      end
    else
      # mfa is nil
      return true
    end
  end

  def sign_in
    if verify_mfa(params[:email]) == false
      # error responses are handled by the verify_mfa method
      return
    end

    result = @user_manager.sign_in(params[:email], params[:password])
    if result[:error]
      render :json => result, :status => 401
    else
      render :json => result
    end
  end

  def register
    if !params[:version]
      params[:version] = "002"
    end

    result = @user_manager.register(params[:email], params[:password], params)
    if result[:error]
      render :json => result, :status => 401
    else
      render :json => result
    end
  end

  def change_pw
    if !params[:current_password]
      render :json => {:error => {:message => "Your current password is required to change your password. Please update your application if you do not see this option."}}, :status => 401
      return
    end

    # Verify current password first
    sign_in_result = @user_manager.sign_in(current_user.email, params[:current_password])
    if sign_in_result[:error]
      render :json => {:error => {:message => "The current password you entered is incorrect. Please try again."}}, :status => 401
      return
    end
    
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
    if verify_mfa(params[:email]) == false
      # error responses are handled by the verify_mfa method
      return
    end

    auth_params = @user_manager.auth_params(params[:email])
    if !auth_params
      render :json => {:error => {:message => "Unable to locate account for email."}}, :status => 404
    else
      render :json => @user_manager.auth_params(params[:email])
    end
  end

end
