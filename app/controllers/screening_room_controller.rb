class ScreeningRoomController < ApplicationController

 def index
  @movie_title = "6 hours of tropical fish"
  @page_title =  @page_title + " - "  + @movie_title
  @movie_time = Time.gm(2015,07,03,18,30)
  @page_title = "▶︎ " + @page_title if (@movie_time < Time.now)
  @youtube_video_id = "zJ7hUvU-d2Q"
  @movie_length = 6 * 60 * 60
  @meta_refresh_times = []
#  @meta_refresh_times << (@movie_time - Time.now).round if (@movie_time > Time.now)
#  @meta_refresh_times << (@movie_time - Time.now + @movie_length).round if ((@movie_time + @movie_length) < Time.now)
 end

end
