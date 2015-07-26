class MhRadioController < ApplicationController

 def index
  @page_title = "▶︎ " + @page_title+ " - Radio"
  if request.post?
   @song = RadioSong.new
   @song.identifier = params[:identifier]
   @song.source_ip = request.remote_ip
   @song.session_id = session.id if session.id
   if @song.save
    flash[:notice] = "Song added!!"
   else
    flash[:notice] = @song.errors.full_messages.to_sentence
    redirect_to :action => :index
   end
  else
   if session[:last_song_played]
    @song = RadioSong.select("random(),*").where(["id != ?", session[:last_song_played]]).order("random").first # TODO: let's later make this a bit more intelligent.. shuffle instead of random
   else
    @song = RadioSong.select("random(),*").order("random").first # TODO: let's later make this a bit more intelligent.. shuffle instead of random
   end
  end
  session[:last_song_played] = @song.id
 end

 def submitted_songs
  @page_title =  @page_title + " - Submitted Songs"
  @user_session_id = session.id
  @songs = RadioSong.order("id desc")
 end

 def delete
  @song = RadioSong.find(params[:id])
  if (@superuser || (@queued_movie.session_id == @user_session_id))
   @sone.destroy
   flash[:notice] = "Song removed."
  end
  redirect_to :action => :submitted_songs
 end

 # Simple status for AJAX... TODO: adapt this for the radio station
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
