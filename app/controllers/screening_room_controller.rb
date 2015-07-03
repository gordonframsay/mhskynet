class ScreeningRoomController < ApplicationController

 def index
  @movie_title = "1958 The Brain Eaters"
  @movie_time = Time.gm(2015,07,03,02,30)
  @movie_url = "https://youtu.be/hOrP34Q-1BA"
 end

end
