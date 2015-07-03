class ScreeningRoomController < ApplicationController

 def index
  @movie_title = "Plan Nine from Outer Space (1959)"
  @movie_time = Time.gm(2015,07,03,05,0)
  @movie_url = "https://youtu.be/cc-zpN2hQno"
 end

end
