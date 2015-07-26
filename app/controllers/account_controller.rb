class AccountController < ApplicationController

 def admin_login
  result = authenticate_or_request_with_http_basic("Restricted Area") do |username, password|
   ((username == "admin") && (password == get_config("admin_password")))
  end
  logger.warn("Auth result: "+ result.to_s) # HTTP Basic: Access denied. or true
  if (result == true)
   session[:superuser] = true
   flash[:notice] = "Logged in as Admin."
   redirect_to '/'
  else
   session[:superuser] = false
  end
 end

end
