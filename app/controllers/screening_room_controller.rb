class ScreeningRoomController < ApplicationController

 require 'jwt'

 before_filter :protect_screening_room
 before_filter :validate_google_log_in, :only => :schedule_movie

 def google_sign_in
 end

 def google_logout
  flash[:notice] = "You are logged out of Google Sign-In."
  session[:google_id_token] = nil
  session[:decoded_google_id_token] = nil
  redirect_to "/"
 end

 def google_login_completion
  session[:google_id_token] = params[:id_token]
  logger.error("Google ID Token: "+params[:id_token])
  render :text => "OK"
  return false
 end

 def index
  @page_title =  @page_title + " - "  + @movie_title
  @page_title = "▶︎ " + @page_title if (@movie_time < Time.now)
  @meta_refresh_times = []
  @movie_width = (session[:movie_width])?(session[:movie_width]):780
  @movie_height = (session[:movie_height])?(session[:movie_height]):650
  @forum_width =  (session[:forum_width])?(session[:forum_width]):500
 end

 def set_sizes
  if request.post?
   session[:movie_width] = params[:movie_width].to_i
   session[:movie_height] = params[:movie_height].to_i
   session[:forum_width] = params[:forum_width].to_i
   flash[:notice] = "Sizing saved!"
  end
  @movie_width = (session[:movie_width])?(session[:movie_width]):780
  @movie_height = (session[:movie_height])?(session[:movie_height]):650
  @forum_width =  (session[:forum_width])?(session[:forum_width]):500
 end

 def change_time_zone
  if request.post?
   session[:user_time_zone] = params[:time_zone]
   flash[:notice] = "Time zone set to "+params[:time_zone]
   redirect_to '/'
  end
 end

 def currently_playing_moviesign
  movie_sign = ((@movie_time - Time.now - 300) * 1000).round
  render :text => (movie_sign > 0)?(movie_sign.to_s):"0"
 end

 def history
  @page_title =  @page_title + " - Scheduled Movies"
  @user_session_id = session.id
 end

 def delete
  @queued_movie = QueuedMovie.find(params[:id])
  if (@superuser || (@queued_movie.session_id == session.id))
   @queued_movie.destroy
   flash[:notice] = "Movie removed from the schedule."
  end
  redirect_to '/screening_room/history/'+@screening_room.to_s
 end

 def schedule_movie
  @google_domain_api_key = get_config("google_api_key")
  @page_title =  @page_title + " - Schedule Movie"
  if (params[:id])
   @queued_movie = QueuedMovie.find(params[:id])
   unless (@superuser || (@queued_movie.session_id == session.id)) # TODO: Make sure this works right.
    flash[:notice] = "Only admins or the original scheduler can edit this scheduled movie!"
    redirect_to '/'
    return false
   end
  else
   @queued_movie = QueuedMovie.new
   @queued_movie.notes = session[:decoded_google_id_token]["name"]
   @queued_movie.screening_room = @screening_room
   @queued_movie.start_time = ActiveSupport::TimeZone.new(@movie_time_zone).now
   @queued_movie.service = "youtube"
  end
  if ((@queued_movie.duration) && ! params[:hours])
   @hours = @queued_movie.duration / (60 * 60)
   @minutes = (@queued_movie.duration / 60) % 60
   @seconds = @queued_movie.duration % 60
  else
   @hours = (params[:hours])?(params[:hours].to_i):0
   @minutes = (params[:minutes])?(params[:minutes].to_i):0
   @seconds = (params[:seconds])?(params[:seconds].to_i):0
  end
  the_time = @queued_movie.start_time.in_time_zone(@movie_time_zone)
  if params[:start_time_zone]
   @movie_time_zone = params[:start_time_zone]
   session[:user_time_zone] = @movie_time_zone
   time_without_zone = params[:start_year]+"/"+params[:start_month]+"/"+params[:start_day]+" "+params[:start_hour]+":"+params[:start_minute]+" "+params[:start_am_pm]
   the_time = ActiveSupport::TimeZone.new(@movie_time_zone).parse(time_without_zone)
  end
  @start_year = the_time.year
  @start_month = the_time.month
  @start_day = the_time.day
  @start_hour = the_time.strftime("%l").to_i
  @start_minute = the_time.min
  @start_am_pm = the_time.strftime("%p")
  if request.post?
   @queued_movie.terms = params[:queued_movie][:terms].to_i if params[:queued_movie][:terms]
   if params[:id]
    @queued_movie = QueuedMovie.find(params[:id])
    @queued_movie.update(params[:queued_movie].permit!)
   else
    @queued_movie = QueuedMovie.new(params[:queued_movie].permit!)
   end
   @screening_room = @queued_movie.screening_room
   @queued_movie.start_time = the_time.gmtime
   @queued_movie.duration = (60 * 60 * @hours) + (60 * @minutes) + @seconds
   if @queued_movie.new_record?
    @queued_movie.source_ip = request.remote_ip
    @queued_movie.session_id = session.id
    @queued_movie.marshalled_google_user_token = Marshal.dump(session[:decoded_google_id_token])
   end
   #
   # People often use the wrong URLs when sharing from Google Drive... *grumble*
   # https://drive.google.com/open?id=0B-tf8af5rnI7UzVkOGRTS3dHZFk
   # https://drive.google.com/file/d/0B-tf8af5rnI7UzVkOGRTS3dHZFk/view?usp=sharing
   #
   if (@queued_movie.service == "html5")
    @queued_movie.identifier = "http://www.googledrive.com/host/"+$1 if @queued_movie.identifier.match(/^https:\/\/drive.google.com\/open\?id=(.*)$/)
    @queued_movie.identifier = "http://www.googledrive.com/host/"+$1 if @queued_movie.identifier.match(/^https:\/\/drive.google.com\/file\/d\/([^\/]+)\/view\?usp=sharing$/)
   end
   if @queued_movie.save
    flash[:notice] = "Media Queued!"
    redirect_to "/screening_room/history/"+@screening_room.to_s
   else
    flash[:notice] = @queued_movie.errors.full_messages.to_sentence
   end
  end
  return true
 end

 def edit
  return false unless schedule_movie
  @queued_movie = QueuedMovie.find(params[:id])
  render :action => :schedule_movie
 end

 # Simple status for AJAX
 def currently_playing
  if (@movie_time > Time.now)
   render :text => "<a href=\"/screening_room\" >Next Movie: <i>"+@movie_title+"</i> -  Starts At: <i>"+@movie_time.in_time_zone(@movie_time_zone).strftime("%b %e %l:%M %p %Z")+"</i></a>"
  else
   if ((@movie_time + @movie_length) > Time.now)
    render :text => "<a href=\"/screening_room\" >Now Playing: <i>"+@movie_title+"</i> -  Started At: <i>"+@movie_time.in_time_zone(@movie_time_zone).strftime("%b %e %l:%M %p %Z")+"</i></a>"
   end
  end
 end

 private

 def protect_screening_room
  if (@screening_room == 9)
    authenticate_or_request_with_http_basic("Screening Room #"+@screening_room.to_s) do |username, password|
      ((username == "mh") && (password == get_config("screening_room_9_password")))
    end
  end
 end

 def validate_google_log_in
  if session[:google_id_token]
   begin
    decoded_token = JWT.decode session[:google_id_token], nil, false
   rescue
    flash[:notice] = ($!).to_s+", please try to log-in again."
    render :action => 'google_sign_in'
    return false
   end
   logger.error("Decoded Google ID Token: "+(decoded_token.inspect))
   if ((decoded_token.first["iss"] == "accounts.google.com") && (decoded_token.first["aud"] == get_config("google_api_client_id")) && (Time.at(decoded_token.first["exp"]) > Time.now))  # Validity test
    session[:decoded_google_id_token] = decoded_token.first
    flash[:notice] = "Logged in as "+(decoded_token.first["name"])+"."
    return true
   end
  end
  session[:google_id_token] = nil
  session[:decoded_google_id_token] = nil
  flash[:notice] = "Please log-in to continue."
  render :action => 'google_sign_in'
  return false
 end

end
