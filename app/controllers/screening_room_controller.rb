class ScreeningRoomController < ApplicationController

 def index
  @movie_title = "Plan Nine from Outer Space (1959)"
  @movie_time = Time.gm(2015,07,03,05,0)
  @movie_url = "https://youtu.be/cc-zpN2hQno"
  @movie_length = 4701
  @meta_refresh_times = []
  @meta_refresh_times << (@movie_time - Time.now).round if (@movie_time > Time.now)
#  @meta_refresh_times << (@movie_time - Time.now + @movie_length).round if ((@movie_time + @movie_length) < Time.now)
 end

end
