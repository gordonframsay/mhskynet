class ScreeningRoomController < ApplicationController

 def index
  @page_title =  @page_title + " - "  + @movie_title
  @page_title = "▶︎ " + @page_title if (@movie_time < Time.now)
  @meta_refresh_times = []
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
   if params[:id]
    @queued_movie = QueuedMovie.find(params[:id])
    @queued_movie.update(params[:queued_movie].permit!)
    # TODO: make sure duration changes/time save, too
   else
    @queued_movie = QueuedMovie.new(params[:queued_movie].permit!)
   end
   @queued_movie.start_time = the_time.gmtime
   @queued_movie.source_ip = request.remote_ip
   @queued_movie.duration = (60 * 60 * @hours) + (60 * @minutes) + @seconds
   @queued_movie.session_id = session.id
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

end
