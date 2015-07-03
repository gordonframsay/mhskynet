class ScreeningRoomController < ApplicationController

 def index
  @movie_title = "Pogo - Wizard of Meh - 10 hours"
  @movie_time = Time.gm(2015,07,03,17,30)
  @youtube_video_id = "3-B2cuFH6oc"
  @movie_length = 10 * 60 * 60
  @meta_refresh_times = []
#  @meta_refresh_times << (@movie_time - Time.now).round if (@movie_time > Time.now)
#  @meta_refresh_times << (@movie_time - Time.now + @movie_length).round if ((@movie_time + @movie_length) < Time.now)
 end

end
