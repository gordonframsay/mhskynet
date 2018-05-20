class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :domain_check
  before_filter :app_defaults
  before_filter :before_filter_check_ip
  before_filter :movie_prep

 # For testing with Google APIs
 def oauth2callback
  logger.warn(params.inspect)
  render :text => "nothing"
 end

 private

  def cors
   headers['Access-Control-Allow-Origin'] = '*'
   headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
#   headers['Access-Control-Request-Method'] = '*'
#   headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
#   headers['Access-Control-Allow-Headers'] = '*'
  end

  def get_config(key_name)
   site_default = SiteDefault.where(["key_name = ?", key_name]).first
   raise "Key not found: "+key_name unless site_default
   return site_default.key_value # TODO: handle various value types.. e.g. integers, etc.
  end

  def domain_check
   redirect_to 'http://www.mhsky.net/' and return false unless ((Rails.env.to_s != 'production') || (request.host == 'www.mhsky.net'))
  end

  def movie_prep
   @screening_room = (params[:screening_room])?(params[:screening_room].to_i):1
   @movie_time_zone = (session[:user_time_zone])?(session[:user_time_zone]):"Pacific Time (US & Canada)"
   m = QueuedMovie.where(["screening_room = ?", @screening_room]).order("start_time").reject {|x| (x.start_time + x.duration) < Time.now }.first
   if m
    @movie = m
    @movie_title = m.title
    @movie_identifier = m.identifier
    @movie_length = m.duration
    @movie_time = m.start_time
    @movie_service = m.service
    @live_event = m.live_event?
    @play_movie_now = m.auto_play_now?
   else
    @live_event = true
    @movie_title = "Kitten Academy Live Stream"
    @movie_identifier = "68deEAd37Zs"
    @movie_length = 100000000
    @movie_time = Time.gm(2017,6,20,0)
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
   logger.error("Visit from "+(request.remote_ip.to_s)+" - "+(session.id.to_s)+" "+((request.user_agent)?(request.user_agent):"(No user agent)"))
   session[:source_ip] = request.remote_ip.to_s
   session[:user_agent] = request.user_agent 
   if (session[:poisoned_session] || (tmp = BlockedIp.where(["address = ?", request.remote_ip]).first))
    result = authenticate_or_request_with_http_basic("Restricted Area") do |username, password|
     ((username == "mh") && (password == get_config("site_password")))
    end
    if (result == true)
     session[:poisoned_session] = false
     flash[:notice] = "Logged in."
    else
     logger.error("Blocked user: on IP ban list - "+(request.remote_ip.to_s)+" "+(session.id.to_s))
     session[:poisoned_session] = true
    end
    return false
   end
   if (tmp = CachedIp.where(["address = ?", request.remote_ip]).first)
    if ((Time.now - tmp.created_at) > 3600)  # NOTE: IP_CACHE_TIMEOUT is in seconds
     tmp.destroy
    elsif (tmp.blocked?)
     logger.error("Blocked user: "+tmp.reason)
     authenticate_or_request_with_http_basic("Restricted Area") do |username, password|
      ((username == "mh") && (password == get_config("site_password")))
     end
     return false
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
    result = authenticate_or_request_with_http_basic("Restricted Area") do |username, password|
     ((username == "mh") && (password == get_config("site_password")))
    end
    if (result == true)
     session[:poisoned_session] = false
     CachedIp.delete_all(:address => request.remote_ip)
     flash[:notice] = "Logged in. Warning: In the future you could be blocked for "+block_reason+"."
    else
     logger.error("Blocked user: "+block_reason)
     session[:poisoned_session] = true
    end
    CachedIp.new(:address => request.remote_ip, :reason => block_reason, :blocked => 1).save!
    return false
   else
# TODO: This creates too many rows right now:
#    CachedIp.new(:address => request.remote_ip, :reason => "(none)", :blocked => 0).save!
   end
   return true
  end

 private

 def check_login
  unless session[:superuser]
   redirect_to '/account/admin_login'
   return false
  end
 end

 def set_title
  @page_title =  @page_title + " - "  + params[:action].titleize unless (params[:action] == "index")
 end

end
