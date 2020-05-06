class MhRadioController < ApplicationController

 # Temp test page
 def google_test
  @google_domain_api_key = get_config("google_api_key")
 end

 def index
  @page_title = "▶︎ " + @page_title+ " - Radio"
  if (request.post? && params[:identifier])
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
   # Creates a random shuffle every hour
   @songs = RadioSong.select("md5(identifier || '"+Time.now.strftime("%a %b %e %H %Y")+"'),*").order("md5")
   if cookies[:mh_radio_playlist]
    @play_list = JSON.parse(cookies[:mh_radio_playlist])
    last_updated = cookies[:mh_radio_playlist_last_updated].to_time
    @play_list += RadioSong.where(["created_at > ?", last_updated]).map {|x| x.id }
    @play_list.uniq!
   else
    @play_list = @songs.map {|x| x.id }
   end
   if params[:do_not_play]
    @play_list.reject! {|x| x == params[:current_song].to_i }
    cookies.permanent[:mh_radio_playlist] = JSON.generate(@play_list)
    cookies.permanent[:mh_radio_playlist_last_updated] = Time.now.gmtime.to_s
   end
   @songs = @songs.reject {|x| ! @play_list.include?(x.id) } # TODO: not sure why reject! doesn't work here... grumble
   if session[:last_song_played_index]
    session[:last_song_played_index] += 1
    @song = @songs[session[:last_song_played_index] % @songs.length]
   else
    session[:last_song_played_index] = 0
    @song = @songs.first
   end
   flash[:notice] = "Playing index: "+session[:last_song_played_index].to_s if (Rails.env.to_s == "development")
  end
 end

 def submitted_songs
  @google_domain_api_key = get_config("google_api_key")
  @page_title =  @page_title + " - Submitted Songs"
  @user_session_id = session.id
  @songs = RadioSong.order("id desc")
  if cookies[:mh_radio_playlist]
   @play_list = JSON.parse(cookies[:mh_radio_playlist])
   last_updated = cookies[:mh_radio_playlist_last_updated].to_time
   @play_list += RadioSong.where(["created_at > ?", last_updated]).map {|x| x.id }
   @play_list.uniq!
  else
   @play_list = @songs.map {|x| x.id }
  end
  if request.post?
   if (params[:play_list])
    @play_list = params[:play_list].keys.map {|x| x.to_i }
   else
    @play_list = @songs.map {|x| x.id }
   end
   cookies.permanent[:mh_radio_playlist] = JSON.generate(@play_list)
   cookies.permanent[:mh_radio_playlist_last_updated] = Time.now.gmtime.to_s
  end
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
   render :plain => "<a href=\"/screening_room\" >Next Movie: <i>"+@movie_title+"</i> -  Starts At: <i>"+@movie_time.in_time_zone(@movie_time_zone).strftime("%b %e %l:%M %p %Z")+"</i></a>"
  else
   if ((@movie_time + @movie_length) > Time.now)
    render :plain => "<a href=\"/screening_room\" >Now Playing: <i>"+@movie_title+"</i> -  Started At: <i>"+@movie_time.in_time_zone(@movie_time_zone).strftime("%b %e %l:%M %p %Z")+"</i></a>"
   end
  end
 end

end
