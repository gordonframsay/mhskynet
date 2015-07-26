class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :domain_check
  before_filter :app_defaults
  before_filter :before_filter_check_ip
  before_filter :movie_prep

 private

  def get_config(key_name)
   site_default = SiteDefault.where(["key_name = ?", key_name]).first
   raise "Key not found: "+key_name unless site_default
   return site_default.key_value # TODO: handle various value types.. e.g. integers, etc.
  end

  def domain_check
   redirect_to 'http://www.mhsky.net/' and return false unless ((Rails.env.to_s != 'production') || (request.host == 'www.mhsky.net'))
  end

  def movie_prep
   @movie_time_zone = (session[:user_time_zone])?(session[:user_time_zone]):"Pacific Time (US & Canada)"
   m = QueuedMovie.order("start_time").reject {|x| (x.start_time + x.duration) < Time.now }.first
   if m
    @movie = m
    @movie_title = m.title
    @movie_identifier = m.identifier
    @movie_length = m.duration
    @movie_time = m.start_time
    @movie_service = m.service
    @live_event = m.live_event?
   else
    @live_event = true
    @movie_title = "Testing"
    @movie_identifier = "GcQqI9wmSyI"
    @movie_length = 100000000
    @movie_time = Time.gm(2015,7,10,20)
    @movie_service = "youtube"
   end
  end

  def app_defaults
   @page_title = "MH Skynet"
   @superuser = session[:superuser]
   Session.clean_up
  end

  def before_filter_check_ip
   return true if ((params[:controller] == "admin") || @superuser)
   if (tmp = BlockedIp.where(["address = ?", request.remote_ip]).first)
#    flash[:notice] = "Your IP has been blocked.  Please contact the site administrators to unblock."
    authenticate_or_request_with_http_basic("Restricted Area") do |username, password|
     ((username == "mh") && (password == MH_USER_PASS))
    end
#    render 'security/password_prompt'
    return false
   end
#   if (request.post? && (params[:forum_password] == FORUM_PASSWORD))
#    CachedIp.delete_all(:address => request.remote_ip)
#    return true
#   end
   if (tmp = CachedIp.where(["address = ?", request.remote_ip]).first)
    if ((Time.now - tmp.created_at) > 3600)  # NOTE: IP_CACHE_TIMEOUT is in seconds
     tmp.destroy
    elsif (tmp.blocked?)
#     flash[:notice] = "Warning:  In the future you could be blocked because of "+tmp.reason+"."
     authenticate_or_request_with_http_basic("Restricted Area") do |username, password|
      ((username == "mh") && (password == MH_USER_PASS))
     end
     return false
#     render 'security/password_prompt'
#     return false
    else
     return true
    end
   end
   block_reason = nil
   begin
    sorbs_listing = Resolver(request.remote_ip.split('.').reverse.join('.')+".dnsbl.sorbs.net").answer.first
   rescue
    sorbs_listing = nil
   end
#   sorbs_listing = Resolver("153.157.15.24.dnsbl.sorbs.net").answer.first
   # TODO: This could be moved to an initializer or something to get it out of the contoller
   sorbs_result_table = {
	"127.0.0.2" => "open HTTP Proxy",
	"127.0.0.3" => "open SOCKS Proxy",
	"127.0.0.4" => "SORBS Misc",
	"127.0.0.5" => "open SMTP Proxy",
	"127.0.0.6" => "SORBS Spam Source",
	"127.0.0.7" => nil, # Vulnerable Web Site
	"127.0.0.8" => "SORBS Block",
	"127.0.0.9" => "SORBS Zombie",
	"127.0.0.10" => nil, # dul
	"127.0.0.11" => "SORBS Bad Config",
	"127.0.0.12" => "SORBS No Mail",
	"127.0.0.14" => nil # noserver
	}
   sorbs_result_table.default = "SORBS (unknown)"
   if (sorbs_listing && sorbs_result_table[sorbs_listing.address.to_s])
    block_reason = "coming from "+sorbs_result_table[sorbs_listing.address.to_s]
   end
   begin
    block_reason = "coming from a Tor Exit Node" unless (Resolver(request.remote_ip.split('.').reverse.join('.')+".torexit.dan.me.uk").answer.empty?)
   rescue
    block_reason = nil
   end
   if block_reason
    CachedIp.delete_all(:address => request.remote_ip)
    flash[:notice] = "Warning: In the future you could be blocked for "+block_reason+"."
    CachedIp.new(:address => request.remote_ip, :reason => block_reason, :blocked => 1).save!
#    render 'security/password_prompt'
#    return false
   else
#    CachedIp.new(:address => request.remote_ip, :reason => "(none)", :blocked => 0).save!
   end
   return true
  end

end
