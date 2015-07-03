class ScreeningRoomController < ApplicationController

 def index
  @movie_title = "The Three Stooges Best Episodes Ever"
  @movie_time = Time.gm(2015,07,03,15,30)
  @youtube_video_id = "YLEMvJZ-X1c"
  @movie_length = 7018
  @meta_refresh_times = []
#  @meta_refresh_times << (@movie_time - Time.now).round if (@movie_time > Time.now)
#  @meta_refresh_times << (@movie_time - Time.now + @movie_length).round if ((@movie_time + @movie_length) < Time.now)
 end

end
