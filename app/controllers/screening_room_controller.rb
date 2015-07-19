class ScreeningRoomController < ApplicationController

 def index
  @page_title =  @page_title + " - "  + @movie_title
  @page_title = "▶︎ " + @page_title if (@movie_time < Time.now)
  @meta_refresh_times = []
 end

 def currently_playing_moviesign
  movie_sign = ((@movie_time - Time.now - 300) * 1000).round
  render :text => (movie_sign > 0)?(movie_sign.to_s):"0"
 end

 def history
  @movie_time_zone = (session[:user_time_zone])?(session[:user_time_zone]):"Pacific Time (US & Canada)"
  @page_title =  @page_title + " - Scheduled Movies"
 end

 def schedule_movie
  @page_title =  @page_title + " - Schedule Movie"
  @queued_movie = QueuedMovie.new
  @queued_movie.start_time = Time.now
  @queued_movie.service = "youtube"
  @hours = (params[:hours])?(params[:hours].to_i):0
  @minutes = (params[:minutes])?(params[:minutes].to_i):0
  @seconds = (params[:seconds])?(params[:seconds].to_i):0
  @start_time_zone = (session[:user_time_zone])?(session[:user_time_zone]):"Pacific Time (US & Canada)"
  the_time = Time.now.in_time_zone(@start_time_zone)
  if params[:start_time_zone]
   @start_time_zone = params[:start_time_zone]
   session[:user_time_zone] = @start_time_zone
   time_without_zone = params[:start_year]+"/"+params[:start_month]+"/"+params[:start_day]+" "+params[:start_hour]+":"+params[:start_minute]+" "+params[:start_am_pm]
   the_time = ActiveSupport::TimeZone.new(@start_time_zone).parse(time_without_zone)
  end
  @start_year = the_time.year
  @start_month = the_time.month
  @start_day = the_time.day
  @start_hour = the_time.strftime("%l").to_i
  @start_minute = the_time.min
  @start_am_pm = the_time.strftime("%p")
  if request.post?
   @queued_movie = QueuedMovie.new(params[:queued_movie].permit!)
   @queued_movie.start_time = the_time.gmtime
   @queued_movie.source_ip = request.remote_ip
   @queued_movie.duration = (60 * 60 * @hours) + (60 * @minutes) + @seconds
   if @queued_movie.save
    flash[:notice] = "Media Queued!"
    redirect_to :action => "schedule_movie"
   else
    flash[:notice] = @queued_movie.errors.full_messages.to_sentence
   end
  end
 end

 # Simple status for AJAX
 def currently_playing
  if (@movie_time > Time.now)
   render :text => "<a href=\"/screening_room\" >Next Movie: <i>"+@movie_title+"</i> -  Starts At: <i>"+@movie_time.in_time_zone("America/Los_Angeles").strftime("%b %e %l:%M %p")+" PST</i></a>"
  else
   if ((@movie_time + @movie_length) > Time.now)
    render :text => "<a href=\"/screening_room\" >Now Playing: <i>"+@movie_title+"</i> -  Started At: <i>"+@movie_time.in_time_zone("America/Los_Angeles").strftime("%b %e %l:%M %p")+" PST</i></a>"
   end
  end
 end

end
