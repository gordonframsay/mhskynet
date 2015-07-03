class ScreeningRoomController < ApplicationController

 def index
  @movie_title = "The Water Boy"
  @movie_time = Time.gm(2015,07,02,23)
  @movie_url = "https://youtu.be/ireAN7EnhfU"
 end

end
