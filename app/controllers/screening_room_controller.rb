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

end
