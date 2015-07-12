class ScreeningRoomController < ApplicationController

 def index
  @page_title =  @page_title + " - "  + @movie_title
  @page_title = "▶︎ " + @page_title if (@movie_time < Time.now)
  @meta_refresh_times = []
 end

 def history
 end

 def schedule_movie
  @queued_movie = QueuedMovie.new
  @queued_movie.start_time = Time.now
  @queued_movie.service = "youtube"
  if request.post?
   @queued_movie = QueuedMovie.new(params[:queued_movie].permit!)
   if @queued_movie.save
    flash[:notice] = "Media Queued!"
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
