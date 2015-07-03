class ScreeningRoomController < ApplicationController

 def index
  @movie_title = "Coming soon..."
  @movie_time = Time.gm(2015,07,03,05,0)
  @movie_url = "https://youtu.be/PhxE1RFtAWY"
 end

end
