class ScreeningRoomController < ApplicationController

 def index
  @movie_title = "Coming soon..."
  @movie_time = Time.gm(2015,07,03,02,30)
  @movie_url = "https://youtu.be/zFjLSlTMV2k"
 end

end
