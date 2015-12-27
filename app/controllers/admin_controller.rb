class AdminController < ApplicationController

 before_filter :check_login

 def index
 end

 def geolocate
 end

 # Makes it so if this user returns with this session, they need to log-in
 def poison_session
  s = Session.find(params[:id])
  s.persistent = 1
  session_data = Marshal.load(Base64.decode64(s.data))
  session_data[:poisoned_session] = true
  s.data = Base64.encode64(Marshal.dump(session_data))
  s.save!
  flash[:notice] = "Session poisoned."
  redirect_to :action => 'index'
 end

 def blocked_ips
  @blocked_ips = BlockedIp.all.order("created_at")
 end

 def new_blocked_ip
  if request.post?
   @blocked_ip = BlockedIp.new(params[:blocked_ip].permit!)
   if @blocked_ip.save
    flash[:notice] = "Saved!"
    redirect_to :action => 'blocked_ips'
   else
    flash[:notice] = @blocked_ip.errors.full_messages.to_sentence
   end
  else
   @blocked_ip = BlockedIp.new
  end
 end

 def delete_blocked_ip
  @blocked_ip = BlockedIp.find(params[:id])
  @blocked_ip.destroy
  flash[:notice] = "Deleted!"
  redirect_to :action => 'blocked_ips'
 end

end
