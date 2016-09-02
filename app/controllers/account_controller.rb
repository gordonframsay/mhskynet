class AccountController < ApplicationController

 before_filter :config_duo_web
 skip_before_action :verify_authenticity_token

 def admin_login
  result = authenticate_or_request_with_http_basic("Restricted Area") do |username, password|
   session[:username] = username
   ((["admin","phil","rocco"].include?(username)) && (password == get_config("admin_password")))
  end
  logger.warn("Auth result: "+ result.to_s) # HTTP Basic: Access denied. or true
  if (result == true)
   @sig_request = Duo.sign_request(@ikey, @skey, @akey, session[:username])
   render :action => 'admin_login_duo'
  else
   session[:superuser] = false
  end
 end

 def admin_logout
  session[:superuser] = false
  flash[:notice] = "You are logged out."
  redirect_to '/'
 end

 def admin_login_duo
 end

 def admin_login_duo_callback
  authenticated_username = Duo.verify_response(@ikey, @skey, @akey, params[:sig_response])
  logger.warn("authenticated_username = " + authenticated_username.to_s)
  if authenticated_username
   session[:superuser] = true
   flash[:notice] = "Logged in as an Admin."
   redirect_to '/admin/'
  else
   flash[:notice] = "Log in failed."
   redirect_to '/'
  end
 end


 private

  def config_duo_web
   @ikey = get_config("duo_ikey")
   @skey = get_config("duo_skey")
   @akey = get_config("duo_akey")
   @api_host = get_config("duo_api_host")
  end

end
