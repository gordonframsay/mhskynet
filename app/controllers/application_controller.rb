class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :before_filter_check_ip

 private

  def before_filter_check_ip
   return true if (params[:controller] == "admin")
   if (tmp = BlockedIp.where(["address = ?", request.remote_ip]).first)
    flash[:notice] = "Your IP has been blocked.  Please contact the site administrators to unblock."
    render 'security/password_prompt'
    return false
   end
   if (request.post? && (params[:forum_password] == FORUM_PASSWORD))
    CachedIp.delete_all(:address => request.remote_ip)
    return true
   end
   if (tmp = CachedIp.where(["address = ?", request.remote_ip]).first)
    if ((Time.now - tmp.created_at) > 3600)  # NOTE: IP_CACHE_TIMEOUT is in seconds
     tmp.destroy
    elsif (tmp.blocked?)
     flash[:notice] = "Warning:  In the future you could be blocked because of "+tmp.reason+"."
     return true
#     render 'security/password_prompt'
#     return false
    else
     return true
    end
   end
   block_reason = nil
   sorbs_listing = Resolver(request.remote_ip.split('.').reverse.join('.')+".dnsbl.sorbs.net").answer.first
#   sorbs_listing = Resolver("153.157.15.24.dnsbl.sorbs.net").answer.first
   # TODO: This could be moved to an initializer or something to get it out of the contoller
   sorbs_result_table = {
	"127.0.0.2" => "open HTTP Proxy",
	"127.0.0.3" => "open SOCKS Proxy",
	"127.0.0.4" => "SORBS misc",
	"127.0.0.5" => "open SMTP Proxy",
	"127.0.0.6" => "SORBS Spam Source",
	"127.0.0.7" => "SORBS vulnerable web site",
	"127.0.0.8" => "SORBS block",
	"127.0.0.9" => "SORBS zombie",
	"127.0.0.10" => "SORBS dul",
	"127.0.0.11" => "SORBS badconf",
	"127.0.0.12" => "SORBS nomail",
	"127.0.0.14" => "SORBS noserver"
	}
   sorbs_result_table.default = "SORBS (unknown)"
   if sorbs_listing
    block_reason = "coming from "+sorbs_result_table[sorbs_listing.address.to_s]
   end
   block_reason = "coming from a Tor Exit Node" unless (Resolver(request.remote_ip.split('.').reverse.join('.')+".torexit.dan.me.uk").answer.empty?)
   if block_reason
    CachedIp.delete_all(:address => request.remote_ip)
    flash[:notice] = "Warning: In the future you could be blocked for "+block_reason+"."
    CachedIp.new(:address => request.remote_ip, :reason => block_reason, :blocked => 1).save!
#    render 'security/password_prompt'
#    return false
   else
    CachedIp.new(:address => request.remote_ip, :reason => "(none)", :blocked => 0).save!
   end
   return true
  end

end
